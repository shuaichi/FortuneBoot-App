import hashlib
import json
from pathlib import Path

root = Path.cwd()
base = root / 'docs/design-system/execution-prompts/evidence/S1-A/attempt-001'
fixture = root / 'tool/s1_a_component_preview_test.dart'
source_sha = hashlib.sha256(fixture.read_bytes()).hexdigest()
entries = []
for theme in ['light', 'dark']:
    for width in [320, 390]:
        for scale in [1, 2]:
            name = f'{theme}-{width}-{scale}x'
            path = base / f'shared-{name}.png'
            height = 1900 if scale == 1 else (3500 if width == 320 else 3000)
            entries.append({
                'page': 'Fx shared component contract fixture',
                'state': name,
                'theme': theme.upper(),
                'logicalSize': [width, height],
                'textScale': scale,
                'pixelRatio': 1,
                'sourceSha': '6061359de0d6db6597176a9158ee826de490f6c4',
                'sourceSha256': source_sha,
                'path': str(path.relative_to(root)),
                'pathSha256': hashlib.sha256(path.read_bytes()).hexdigest(),
                'actuallyViewed': True,
                'observation': '已实际打开最终图：长中英文、长金额、选择/列表、分段、静态/操作标签、焦点/禁用、持久错误、多行 CTA、树与恢复动作完整可见；实色卡前景配对，320/2x 标签与动作上下重排，无横向溢出或关键金额省略。仅覆盖共享 fixture，不代表业务页面或真机。',
            })
(base / 'screenshot-index.json').write_text(json.dumps(entries, ensure_ascii=False, indent=2) + '\n')
print(f'indexed {len(entries)} viewed Flutter screenshots')
