@echo off
cd /d "%~dp0"
echo.
echo ==========================================================
echo   Created by Oscar Zarraga Perez
echo   Copyright (c) 2026 Oscar Zarraga Perez  -  MIT License
echo ===============================================
echo.
echo Starting Unified Terminal on http://127.0.0.1:8787 ...
echo.
python markets_data_api.py --port 8787
pause
