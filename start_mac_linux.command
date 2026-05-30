#!/usr/bin/env bash
cd "$(dirname "$0")"
echo ""
echo "=========================================================="
echo "  Created by Oscar Zarraga Perez"
echo "  Copyright (c) 2026 Oscar Zarraga Perez  -  MIT License"
echo "==============================================="
echo ""
echo "Starting Unified Terminal on http://127.0.0.1:8787 ..."
echo ""
exec python3 markets_data_api.py --port 8787
