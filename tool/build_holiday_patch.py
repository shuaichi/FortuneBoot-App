#!/usr/bin/env python3
"""把可读的调休表源文件编译成 holiday-patch.json。

源文件每行一条（# 开头为注释，空行忽略）：

  YYYY-MM-DD  休|班  节日名  [对应节日日 YYYY-MM-DD]

示例：
  2027-01-01  休  元旦
  2027-01-02  休  元旦  2027-01-01
  2027-01-03  班  元旦  2027-01-01

节日名（与 lunar HolidayUtil 一致）：
  元旦 / 春节 / 清明 / 劳动 / 端午 / 中秋 / 国庆 / 国庆中秋 / 抗战胜利日
  也可用数字下标 0–8。

用法：
  python tool/build_holiday_patch.py
  python tool/build_holiday_patch.py tool/holiday-patch.source.txt
  python tool/build_holiday_patch.py -i 源.txt -o 输出.json -v 20270101
  python tool/build_holiday_patch.py --init   # 生成示例源文件

默认输出到 assets/calendar/holiday-patch.json（打进安装包）。
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "tool" / "holiday-patch.source.txt"
DEFAULT_OUTPUT = ROOT / "assets" / "calendar" / "holiday-patch.json"
EXAMPLE_SOURCE = ROOT / "tool" / "holiday-patch.source.example.txt"
EXAMPLE_JSON = ROOT / "tool" / "holiday-patch.example.json"

# 与 lunar HolidayUtil.NAMES 下标一致（元旦0 … 抗战胜利日8）
FESTIVAL_NAMES: dict[str, int] = {
    "元旦": 0,
    "元旦节": 0,
    "春节": 1,
    "清明": 2,
    "清明节": 2,
    "劳动": 3,
    "劳动节": 3,
    "端午": 4,
    "端午节": 4,
    "中秋": 5,
    "中秋节": 5,
    "国庆": 6,
    "国庆节": 6,
    "国庆中秋": 7,
    "抗战胜利日": 8,
    "抗战胜利": 8,
}

# 休=放假(1)，班=调休上班(0)
TYPE_REST = {"休", "放假", "假", "rest", "off", "1"}
TYPE_WORK = {"班", "上班", "调休", "work", "on", "0"}

DATE_RE = re.compile(
    r"^(\d{4})[-/.]?(\d{1,2})[-/.]?(\d{1,2})$"
)


def parse_date(text: str) -> date:
    m = DATE_RE.match(text.strip())
    if not m:
        raise ValueError(f"无法解析日期: {text!r}（期望 YYYY-MM-DD 或 YYYYMMDD）")
    y, mo, d = (int(m.group(1)), int(m.group(2)), int(m.group(3)))
    return date(y, mo, d)


def fmt_ymd(d: date) -> str:
    return d.strftime("%Y%m%d")


def resolve_festival(token: str) -> int:
    t = token.strip()
    if t.isdigit():
        idx = int(t)
        if 0 <= idx <= 8:
            return idx
        raise ValueError(f"节日下标超出 0–8: {t}")
    if t in FESTIVAL_NAMES:
        return FESTIVAL_NAMES[t]
    raise ValueError(
        f"未知节日: {t!r}。可选: {', '.join(sorted(set(FESTIVAL_NAMES)))}"
    )


def resolve_type(token: str) -> str:
    """返回 '1'(休) 或 '0'(班)。"""
    t = token.strip().lower()
    # 保留中文原样匹配
    raw = token.strip()
    if raw in TYPE_REST or t in TYPE_REST:
        return "1"
    if raw in TYPE_WORK or t in TYPE_WORK:
        return "0"
    raise ValueError(f"类型须为 休/班，收到: {token!r}")


def encode_segment(
    day: date,
    work_flag: str,
    festival_index: int,
    target: date,
) -> str:
    """18 位：当天YYYYMMDD + 节日下标 + 调休标识 + 对应节日YYYYMMDD。"""
    return f"{fmt_ymd(day)}{festival_index}{work_flag}{fmt_ymd(target)}"


def parse_line(line: str, line_no: int) -> tuple[date, str, int, date] | None:
    raw = line.strip()
    if not raw or raw.startswith("#"):
        return None

    # 支持逗号或空白分隔
    parts = [p for p in re.split(r"[\s,，]+", raw) if p]
    if len(parts) < 3:
        raise ValueError(
            f"第 {line_no} 行字段不足（至少 日期 休|班 节日）: {raw}"
        )
    if len(parts) > 4:
        raise ValueError(f"第 {line_no} 行字段过多: {raw}")

    day = parse_date(parts[0])
    work_flag = resolve_type(parts[1])
    festival_index = resolve_festival(parts[2])
    target = parse_date(parts[3]) if len(parts) == 4 else day
    return day, work_flag, festival_index, target


def load_source(path: Path) -> list[tuple[date, str, int, date]]:
    if not path.is_file():
        raise FileNotFoundError(f"源文件不存在: {path}")
    text = path.read_text(encoding="utf-8-sig")
    rows: list[tuple[date, str, int, date]] = []
    for i, line in enumerate(text.splitlines(), start=1):
        try:
            parsed = parse_line(line, i)
        except ValueError as e:
            raise ValueError(str(e)) from e
        if parsed is not None:
            rows.append(parsed)
    if not rows:
        raise ValueError(f"源文件没有有效行: {path}")
    # 按日期排序，同日后者覆盖前者
    by_day: dict[date, tuple[date, str, int, date]] = {}
    for row in rows:
        by_day[row[0]] = row
    return [by_day[k] for k in sorted(by_day)]


def build_patch(
    rows: list[tuple[date, str, int, date]],
    version: int | None,
) -> dict[str, object]:
    data = "".join(
        encode_segment(day, flag, fest, target)
        for day, flag, fest, target in rows
    )
    if len(data) % 18 != 0:
        raise RuntimeError("内部错误：data 长度不是 18 的倍数")
    if version is None:
        # 默认用源里最大日期作为版本号，便于一眼看出覆盖到哪天
        version = int(fmt_ymd(max(r[0] for r in rows)))
    return {"version": version, "data": data}


EXAMPLE_SOURCE_TEXT = """# 调休补丁源文件
# 每行：日期  休|班  节日  [对应节日日]
# 日期可用 2027-01-01 或 20270101
# 对应节日日可省略，省略时等于当天
#
# 节日：元旦 春节 清明 劳动 端午 中秋 国庆 国庆中秋 抗战胜利日
#
# 示例（2027 元旦）：1 日放假，2 日放假，3 日（周日）调休上班

2027-01-01  休  元旦
2027-01-02  休  元旦  2027-01-01
2027-01-03  班  元旦  2027-01-01
"""


def write_init_files() -> None:
    EXAMPLE_SOURCE.write_text(EXAMPLE_SOURCE_TEXT, encoding="utf-8")
    if not DEFAULT_SOURCE.exists():
        DEFAULT_SOURCE.write_text(EXAMPLE_SOURCE_TEXT, encoding="utf-8")
        print(f"已创建可编辑源文件: {DEFAULT_SOURCE}")
    else:
        print(f"源文件已存在，未覆盖: {DEFAULT_SOURCE}")
    print(f"已写入示例: {EXAMPLE_SOURCE}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="编译 holiday-patch.source.txt → holiday-patch.json",
    )
    parser.add_argument(
        "source",
        nargs="?",
        default=None,
        help=f"源文件路径（默认 {DEFAULT_SOURCE.name}）",
    )
    parser.add_argument(
        "-i",
        "--input",
        dest="input_path",
        help="源文件路径（与位置参数二选一）",
    )
    parser.add_argument(
        "-o",
        "--output",
        default=str(DEFAULT_OUTPUT),
        help=f"输出 JSON 路径（默认 {DEFAULT_OUTPUT.name}）",
    )
    parser.add_argument(
        "-v",
        "--version",
        type=int,
        default=None,
        help="补丁 version 整数（默认取源文件最大日期 YYYYMMDD）",
    )
    parser.add_argument(
        "--init",
        action="store_true",
        help="生成示例源文件后退出",
    )
    parser.add_argument(
        "--print",
        action="store_true",
        dest="print_only",
        help="只打印 JSON，不写文件",
    )
    args = parser.parse_args(argv)

    if args.init:
        write_init_files()
        return 0

    source = Path(args.input_path or args.source or DEFAULT_SOURCE)
    if not source.is_absolute():
        source = (Path.cwd() / source).resolve()
        if not source.is_file():
            alt = (ROOT / "tool" / source.name).resolve()
            if alt.is_file():
                source = alt

    try:
        rows = load_source(source)
        patch = build_patch(rows, args.version)
    except (OSError, ValueError, RuntimeError) as e:
        print(f"错误: {e}", file=sys.stderr)
        return 1

    text = json.dumps(patch, ensure_ascii=False, indent=2) + "\n"
    if args.print_only:
        sys.stdout.write(text)
        return 0

    out = Path(args.output)
    if not out.is_absolute():
        out = (Path.cwd() / out).resolve()
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(text, encoding="utf-8")
    # 同步一份示例到 tool/，方便对照格式
    if out.resolve() == DEFAULT_OUTPUT.resolve():
        EXAMPLE_JSON.write_text(text, encoding="utf-8")

    days = len(patch["data"]) // 18  # type: ignore[operator]
    print(f"已生成: {out}")
    print(f"  version = {patch['version']}")
    print(f"  天数    = {days}")
    print(f"  data 长度 = {len(patch['data'])}")  # type: ignore[arg-type]
    print("发版后会随安装包生效；无需上传服务器。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
