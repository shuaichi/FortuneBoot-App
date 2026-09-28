#!/usr/bin/env python3
"""方案 A：把 assets/icons/banks/*.svg 导出为 assets/images/banks/{id}.png。

用法：
  python tool/export_bank_icons.py

转换器优先级：
  1. cairosvg（pip install cairosvg）
  2. rsvg-convert
  3. inkscape
  4. ImageMagick 的 magick（不会误用 Windows 的 convert.exe）
  5. npx @resvg/resvg-js（需 Node.js）

约定：
  - 源文件可用中文名或英文 id，例如 招商银行.svg / cmb.svg
  - 输出一律按品牌 id：assets/images/banks/cmb.png
  - App 只读 PNG；SVG 不进 Flutter assets
"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "assets" / "icons" / "banks"
OUT_DIR = ROOT / "assets" / "images" / "banks"
SIZE = 256

# 中文 / 别名 → BankBrand.id
NAME_TO_ID: dict[str, str] = {
    "花呗": "huabei",
    "借呗": "huabei",
    "huabei": "huabei",
    "支付宝": "alipay",
    "alipay": "alipay",
    "微信": "wechat",
    "微信支付": "wechat",
    "wechat": "wechat",
    "中国工商银行": "icbc",
    "工商银行": "icbc",
    "工商": "icbc",
    "工行": "icbc",
    "icbc": "icbc",
    "中国建设银行": "ccb",
    "建设银行": "ccb",
    "建行": "ccb",
    "ccb": "ccb",
    "中国农业银行": "abc",
    "农业银行": "abc",
    "农行": "abc",
    "abc": "abc",
    "中国银行": "boc",
    "中行": "boc",
    "boc": "boc",
    "交通银行": "bocom",
    "交行": "bocom",
    "bocom": "bocom",
    "招商银行": "cmb",
    "招行": "cmb",
    "cmb": "cmb",
    "浦发银行": "spdb",
    "浦发": "spdb",
    "spdb": "spdb",
    "中信银行": "citic",
    "中信": "citic",
    "citic": "citic",
    "中国光大银行": "ceb",
    "光大银行": "ceb",
    "光大": "ceb",
    "ceb": "ceb",
    "余额宝": "yuebao",
    "yuebao": "yuebao",
    "网商银行": "mybank",
    "网商": "mybank",
    "mybank": "mybank",
    "芝麻信用": "zhima",
    "芝麻": "zhima",
    "zhima": "zhima",
    "洛阳银行": "lyb",
    "lyb": "lyb",
    "中国人民银行": "pbc",
    "人民银行": "pbc",
    "pbc": "pbc",
    "国家开发银行": "cdb",
    "cdb": "cdb",
    "中国农业发展银行": "adbc",
    "adbc": "adbc",
    "中国进出口银行": "eximbank",
    "eximbank": "eximbank",
    "民生银行": "cmbc",
    "民生": "cmbc",
    "cmbc": "cmbc",
    "兴业银行": "cib",
    "兴业": "cib",
    "cib": "cib",
    "平安银行": "pab",
    "平安": "pab",
    "pab": "pab",
    "华夏银行": "hxb",
    "华夏": "hxb",
    "hxb": "hxb",
    "广发银行": "cgb",
    "广发": "cgb",
    "cgb": "cgb",
    "中国邮政储蓄银行": "psbc",
    "邮储银行": "psbc",
    "邮储": "psbc",
    "邮政储蓄": "psbc",
    "psbc": "psbc",
    "北京银行": "bob",
    "bob": "bob",
    "京东": "jd",
    "白条": "jd",
    "jd": "jd",
    "美团": "meituan",
    "meituan": "meituan",
}


def which(cmd: str) -> str | None:
    return shutil.which(cmd)


def find_node() -> str | None:
    """优先系统 Node，避开 Cursor 自带的 helpers\\node.exe。"""
    candidates: list[str] = []
    for name in ("node", "node.exe"):
        p = which(name)
        if p:
            candidates.append(p)
    # 常见安装路径
    for p in (
        r"C:\Program Files\nodejs\node.exe",
        r"C:\Program Files (x86)\nodejs\node.exe",
    ):
        if Path(p).exists():
            candidates.append(p)

    ranked: list[str] = []
    for p in candidates:
        norm = p.replace("/", "\\").lower()
        if "cursor" in norm and "helpers" in norm:
            continue
        ranked.append(p)
    return ranked[0] if ranked else (candidates[0] if candidates else None)


def find_npm() -> str | None:
    for name in ("npm.cmd", "npm"):
        p = which(name)
        if p:
            return p
    for p in (
        r"C:\Program Files\nodejs\npm.cmd",
        r"C:\Program Files (x86)\nodejs\npm.cmd",
    ):
        if Path(p).exists():
            return p
    return None


def is_imagemagick(path: str) -> bool:
    """排除 Windows\\System32\\convert.exe（那是磁盘转换工具，不是 ImageMagick）。"""
    normalized = path.replace("/", "\\").lower()
    if normalized.endswith("\\system32\\convert.exe"):
        return False
    if normalized.endswith("\\syswow64\\convert.exe"):
        return False
    try:
        out = subprocess.check_output(
            [path, "-version"],
            stderr=subprocess.STDOUT,
            text=True,
            errors="ignore",
        )
        return "ImageMagick" in out
    except Exception:  # noqa: BLE001
        return False


def find_imagemagick() -> str | None:
    magick = which("magick")
    if magick and is_imagemagick(magick):
        return magick
    convert = which("convert")
    if convert and is_imagemagick(convert):
        return convert
    return None


def resolve_brand_id(stem: str) -> str | None:
    if stem in NAME_TO_ID:
        return NAME_TO_ID[stem]
    # 容错：去掉空格
    compact = stem.replace(" ", "")
    return NAME_TO_ID.get(compact)


def export_with_cairosvg(svg: Path, png: Path) -> bool:
    try:
        import cairosvg  # type: ignore
    except ImportError:
        return False
    cairosvg.svg2png(
        url=svg.resolve().as_uri(),
        write_to=str(png),
        output_width=SIZE,
        output_height=SIZE,
    )
    return True


def export_with_rsvg(svg: Path, png: Path) -> bool:
    rsvg = which("rsvg-convert")
    if not rsvg:
        return False
    subprocess.check_call(
        [rsvg, "-w", str(SIZE), "-h", str(SIZE), "-o", str(png), str(svg)]
    )
    return True


def export_with_inkscape(svg: Path, png: Path) -> bool:
    inkscape = which("inkscape")
    if not inkscape:
        return False
    subprocess.check_call(
        [
            inkscape,
            str(svg),
            f"--export-filename={png}",
            f"--export-width={SIZE}",
            f"--export-height={SIZE}",
        ]
    )
    return True


def export_with_magick(svg: Path, png: Path) -> bool:
    magick = find_imagemagick()
    if not magick:
        return False
    subprocess.check_call(
        [
            magick,
            "-background",
            "none",
            str(svg),
            "-resize",
            f"{SIZE}x{SIZE}",
            str(png),
        ]
    )
    return True


def export_with_resvg_js(svg: Path, png: Path) -> bool:
    """单文件模式：直接 spawn node + @resvg/resvg-js。"""
    node = find_node()
    npm = find_npm()
    if not node or not npm:
        return False

    tool_dir = ROOT / "tool"
    resvg_pkg = tool_dir / "node_modules" / "@resvg" / "resvg-js"
    if not resvg_pkg.exists():
        print("正在安装 @resvg/resvg-js 到 tool/ ...")
        subprocess.check_call(
            [npm, "install", "--prefix", str(tool_dir), "@resvg/resvg-js"],
            cwd=str(ROOT),
            shell=False,
        )

    script = f"""
const fs = require('fs');
const {{ Resvg }} = require('@resvg/resvg-js');
const svg = fs.readFileSync({str(svg.resolve())!r});
const resvg = new Resvg(svg, {{
  fitTo: {{ mode: 'width', value: {SIZE} }},
  background: 'rgba(0,0,0,0)',
}});
fs.writeFileSync({str(png.resolve())!r}, resvg.render().asPng());
"""
    subprocess.check_call(
        [node, "-e", script],
        cwd=str(tool_dir),
    )
    return png.exists() and png.stat().st_size > 0


def export_one(svg: Path, png: Path) -> str:
    """成功返回使用的后端名。"""
    errors: list[str] = []
    for name, fn in (
        ("resvg-js", export_with_resvg_js),
        ("cairosvg", export_with_cairosvg),
        ("rsvg-convert", export_with_rsvg),
        ("inkscape", export_with_inkscape),
        ("magick", export_with_magick),
    ):
        try:
            if fn(svg, png) and png.exists() and png.stat().st_size > 0:
                return name
        except Exception as e:  # noqa: BLE001
            errors.append(f"{name}: {e}")
            if png.exists():
                png.unlink(missing_ok=True)

    raise RuntimeError(
        "没有可用的 SVG 转换器。可执行: npm install --prefix tool @resvg/resvg-js\n"
        + ("\n".join(errors) if errors else "")
    )


def main() -> int:
    SRC_DIR.mkdir(parents=True, exist_ok=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)

    svgs = sorted(SRC_DIR.glob("*.svg"))
    if not svgs:
        print(f"未找到 SVG：请放到 {SRC_DIR.as_posix()}/")
        return 0

    # Windows 上优先走 Node/resvg（不依赖 Cairo / 假 convert.exe）
    mjs = ROOT / "tool" / "export_bank_icons.mjs"
    node = find_node()
    npm = find_npm()
    if node and npm and mjs.exists():
        tool_dir = ROOT / "tool"
        resvg_pkg = tool_dir / "node_modules" / "@resvg" / "resvg-js"
        try:
            if not resvg_pkg.exists():
                print("正在安装 @resvg/resvg-js 到 tool/ ...")
                subprocess.check_call(
                    [npm, "install", "--prefix", str(tool_dir), "@resvg/resvg-js"],
                    cwd=str(ROOT),
                )
            print(f"使用 Node @resvg/resvg-js 导出... ({node})", flush=True)
            return subprocess.call([node, str(mjs)], cwd=str(ROOT))
        except Exception as e:  # noqa: BLE001
            print(f"Node 导出失败，回退其它转换器: {e}")

    ok = 0
    failed: list[str] = []
    for svg in svgs:
        brand_id = resolve_brand_id(svg.stem)
        if not brand_id:
            failed.append(svg.name)
            print(
                f"SKIP {svg.name}：无法映射到品牌 id。"
                f"请改名为英文 id（如 cmb.svg），或在脚本 NAME_TO_ID 中补充。"
            )
            continue

        png = OUT_DIR / f"{brand_id}.png"
        try:
            backend = export_one(svg, png)
            print(f"OK  {svg.name} -> {png.relative_to(ROOT)}  [{backend}]")
            ok += 1
        except Exception as e:  # noqa: BLE001
            failed.append(svg.name)
            print(f"FAIL {svg.name}: {e}")

    print(f"完成：成功 {ok}，失败/跳过 {len(failed)}")
    return 0 if ok > 0 and not failed else (0 if ok > 0 else 1)


if __name__ == "__main__":
    sys.exit(main())
