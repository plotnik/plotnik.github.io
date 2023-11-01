
        
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
        
                
            for (xmlName in xmlNames) {
            }
    
                
            // местоположение главного файла незагруженных книг
            ebookFile = '/home/egor/Dropbox/Public/books/bookindex/ebook.txt'
        
            for (txtName in txtNames) {
            }
    

