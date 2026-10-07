@echo off
REM Call from project root, or: call scripts\ohos_env.bat
REM Environment under E:\zhou\WeiHu\fortuneboot\HuanJing ; DevEco Studio remains on D:
REM Flutter SDK also has bin\mingit -> PortableGit so DevEco FlutterTask can find git.
set "HUANJING=E:\zhou\WeiHu\fortuneboot\HuanJing"
set "PATH=D:\DevEco Studio\jbr\bin;%HUANJING%\tools\PortableGit\cmd;%HUANJING%\tools\PortableGit\bin;D:\DevEco Studio\tools\hvigor\bin;D:\DevEco Studio\tools\ohpm\bin;D:\DevEco Studio\tools\node;%HUANJING%\flutter_flutter\bin;%PATH%"
set "JAVA_HOME=D:\DevEco Studio\jbr"
set "DEVECO_SDK_HOME=D:\DevEco Studio\sdk"
set "PUB_CACHE=%HUANJING%\pub-cache"
set "FLUTTER_ROOT=%HUANJING%\flutter_flutter"
echo [ohos_env] FLUTTER_ROOT=%FLUTTER_ROOT%
echo [ohos_env] JAVA_HOME=%JAVA_HOME%
echo [ohos_env] DEVECO_SDK_HOME=%DEVECO_SDK_HOME%
echo [ohos_env] PUB_CACHE=%PUB_CACHE%
