@REM drag and drop ogg on this file to convert to mp3

for %%a in (%*) do (
	ffmpeg -i %%a %%~na.mp3
)