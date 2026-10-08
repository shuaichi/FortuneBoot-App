银行 / 支付品牌 SVG 源目录（方案 A）。

规则：
1. 文件名可用中文或英文 id，例如 招商银行.svg 或 cmb.svg
2. 建议正方形 viewBox，透明底，不要黑底
3. 导出（推荐）：
   python tool/export_bank_icons.py
   或：node tool/export_bank_icons.mjs
4. 首次需：npm install --prefix tool @resvg/resvg-js
5. 导出结果：assets/images/banks/{id}.png（中文名会自动映射，如 招商银行 -> cmb.png）
6. 然后在 bank_brand.dart 把对应品牌的 assetPath 设为该 PNG
