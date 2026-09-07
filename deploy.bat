@echo off
rem Entry point for double-clicking from Explorer. The real launcher is deploy.ps1.
rem Nothing here may rely on PATH: cmd.exe resolves external commands only through
rem it, and an over-long system PATH silently breaks that lookup for every tool.
rem So powershell.exe is called by absolute path, and only the built-in pause is used.

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
pause
