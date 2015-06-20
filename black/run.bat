if %1%==git goto git
C:\Install\Python\pyweb-2.3.2\pyweb.py -w html -n source.w
goto exit

:git
cd ..
git add --all
git commit -m "black"
git push -u origin master 
cd black

:exit