<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Book Index</title>

<link rel="stylesheet" type="text/css" href="../../stylesheets/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="../../stylesheets/plotnik.css">
<style>
code pre {
	background-color: #ddd;
}
</style>

  </head>
  <body>
  
<div class="container">  

  
<h1>Book Index</h1>

<p>Сборка индекса по книгам и поиск дубликатов.</p>
    
@o bookindex.groovy @{
    @<просканировать каталоги за все месяцы@>
@}

<p>Собрать информацию из файлов <b>books.xml</b> и <b>books.txt</b>, 
пропуская папки <b>noBookFolders</b>.
В xml-файлах содержатся списки уже загруженных книг,
а в txt-файлах находятся списки книг, которые мы только собираемся загрузить.
</p>

<p>Отсортировать папки в обратном порядке, чтобы более новые папки
индексировались первыми.</p> 
 
@d просканировать каталоги за все месяцы @{
    // папки, которые мы не будем сканировать
    noBooksFolders = ['bookindex','code']

    // с какой папки начинать сканирование
    bookHome  = '.' 
    
    // сюда мы соберем имена xml-файлов
    xmlNames = []   

    // сюда мы соберем имена txt-файлов
    txtNames = []   

    dirs = new File(bookHome).listFiles()
    for (dir in dirs) {
        if (!dir.isDirectory()) continue;
        if (noBooksFolders.contains(dir.name)) continue;
        
        // xml-файл должен быть в каталоге обязательно
        xmlName = dir.getPath()+'/books.xml'
        xmlNames << xmlName
        
        // а txt-файл - нет
        txtName = dir.getPath()+'/books.txt'
        if (new File(txtName).exists()) {
            txtNames << txtName
        }
    }
    xmlNames.sort { a,b -> -a.compareTo(b) }
    txtNames.sort { a,b -> -a.compareTo(b) }
    
    @<проанализировать все файлы books.xml@>
    @<проанализировать все файлы books.txt@>
@}

@d проанализировать все файлы books.xml @{
    for (xmlName in xmlNames) {
    }
@}

<p>Файл <b>ebook.txt</b> содержит ссылки на книги, которые мы только собираемся загрузить.
Имеется один главный файл, и возможно еще по файлу в каждом из каталогов за месяц.</p>

@d проанализировать все файлы books.txt @{
    // местоположение главного файла незагруженных книг
    ebookFile = '/home/egor/Dropbox/Public/books/bookindex/ebook.txt'

    for (txtName in txtNames) {
    }
@}

</div><!--.container-->

  </body>
</html>
