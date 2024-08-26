@echo off
cd /d "%~dp0"
git pull
git add .
git commit -m "Fixed kings ability to move to cells with enemy figure defended by enemy king. Fixed incorrect overlapping of figures during making a move."
git push