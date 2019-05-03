!macro customInstall
  ExecWait '"$INSTDIR\resources\app\build_resources\win\vc_redist.x64.exe" /install /passive /norestart'
!macroend