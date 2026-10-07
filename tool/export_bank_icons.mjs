/**
 * SVG -> PNG via @resvg/resvg-js（Windows 友好，不依赖 ImageMagick/Cairo）
 *
 * 用法（在项目根目录）：
 *   npm install --prefix tool @resvg/resvg-js
 *   node tool/export_bank_icons.mjs
 * 或由 python tool/export_bank_icons.py 自动调用
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { createRequire } from "node:module";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");
const SRC_DIR = path.join(ROOT, "assets", "icons", "banks");
const OUT_DIR = path.join(ROOT, "assets", "images", "banks");
const SIZE = 256;

const NAME_TO_ID = {
  花呗: "huabei",
  借呗: "huabei",
  huabei: "huabei",
  支付宝: "alipay",
  alipay: "alipay",
  微信: "wechat",
  微信支付: "wechat",
  wechat: "wechat",
  中国工商银行: "icbc",
  工商银行: "icbc",
  工商: "icbc",
  工行: "icbc",
  icbc: "icbc",
  中国建设银行: "ccb",
  建设银行: "ccb",
  建行: "ccb",
  ccb: "ccb",
  中国农业银行: "abc",
  农业银行: "abc",
  农行: "abc",
  abc: "abc",
  中国银行: "boc",
  中行: "boc",
  boc: "boc",
  交通银行: "bocom",
  交行: "bocom",
  bocom: "bocom",
  招商银行: "cmb",
  招行: "cmb",
  cmb: "cmb",
  浦发银行: "spdb",
  浦发: "spdb",
  spdb: "spdb",
  中信银行: "citic",
  中信: "citic",
  citic: "citic",
  中国光大银行: "ceb",
  光大银行: "ceb",
  光大: "ceb",
  ceb: "ceb",
  余额宝: "yuebao",
  yuebao: "yuebao",
  网商银行: "mybank",
  网商: "mybank",
  mybank: "mybank",
  芝麻信用: "zhima",
  芝麻: "zhima",
  zhima: "zhima",
  洛阳银行: "lyb",
  lyb: "lyb",
  中国人民银行: "pbc",
  人民银行: "pbc",
  pbc: "pbc",
  国家开发银行: "cdb",
  cdb: "cdb",
  中国农业发展银行: "adbc",
  adbc: "adbc",
  中国进出口银行: "eximbank",
  eximbank: "eximbank",
  民生银行: "cmbc",
  民生: "cmbc",
  cmbc: "cmbc",
  兴业银行: "cib",
  兴业: "cib",
  cib: "cib",
  平安银行: "pab",
  平安: "pab",
  pab: "pab",
  华夏银行: "hxb",
  华夏: "hxb",
  hxb: "hxb",
  广发银行: "cgb",
  广发: "cgb",
  cgb: "cgb",
  中国邮政储蓄银行: "psbc",
  邮储银行: "psbc",
  邮储: "psbc",
  邮政储蓄: "psbc",
  psbc: "psbc",
  北京银行: "bob",
  bob: "bob",
  京东: "jd",
  白条: "jd",
  jd: "jd",
  美团: "meituan",
  meituan: "meituan",
};

function loadResvg() {
  const require = createRequire(import.meta.url);
  try {
    return require("@resvg/resvg-js");
  } catch {
    // 允许从项目根 node_modules 找
    try {
      return createRequire(pathToFileURL(path.join(ROOT, "package.json")).href)(
        "@resvg/resvg-js",
      );
    } catch {
      console.error(
        "缺少 @resvg/resvg-js。请执行：npm install --prefix tool @resvg/resvg-js",
      );
      process.exit(1);
    }
  }
}

function resolveBrandId(stem) {
  return NAME_TO_ID[stem] || NAME_TO_ID[stem.replace(/\s+/g, "")] || null;
}

const { Resvg } = loadResvg();
fs.mkdirSync(OUT_DIR, { recursive: true });

const svgs = fs
  .readdirSync(SRC_DIR)
  .filter((n) => n.toLowerCase().endsWith(".svg"))
  .sort();

if (svgs.length === 0) {
  console.log(`未找到 SVG：${SRC_DIR}`);
  process.exit(0);
}

let ok = 0;
let failed = 0;
for (const name of svgs) {
  const stem = path.parse(name).name;
  const brandId = resolveBrandId(stem);
  if (!brandId) {
    console.log(`SKIP ${name}：无法映射到品牌 id`);
    failed += 1;
    continue;
  }
  const svgPath = path.join(SRC_DIR, name);
  const pngPath = path.join(OUT_DIR, `${brandId}.png`);
  try {
    const svg = fs.readFileSync(svgPath);
    const resvg = new Resvg(svg, {
      fitTo: { mode: "width", value: SIZE },
      background: "rgba(0,0,0,0)",
    });
    fs.writeFileSync(pngPath, resvg.render().asPng());
    console.log(`OK  ${name} -> assets/images/banks/${brandId}.png`);
    ok += 1;
  } catch (e) {
    console.log(`FAIL ${name}: ${e.message || e}`);
    failed += 1;
  }
}

console.log(`完成：成功 ${ok}，失败/跳过 ${failed}`);
process.exit(failed && !ok ? 1 : 0);
