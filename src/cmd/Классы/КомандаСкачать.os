#Использовать "../../core"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ОписаниеКоманды(Команда) Экспорт

	Команда.Аргумент("PATH", "", "путь к дистрибутиву или прямая ссылка на скачивание")
				.ТСтрока();
				
	Команда.Опция("o out", "./", "каталог сохранения скачиваемых файлов или имя файла (для опции force)")
				.ТСтрока();
				
	Команда.Опция("f force", Ложь, "сохранить принудительно, даже если это не файл")
				.ТБулево();

КонецПроцедуры

// Выполняет логику команды
Процедура ВыполнитьКоманду(Знач Команда) Экспорт
	
	АдресСайта = ПараметрыПриложения.АдресСайта();
	
	Путь = Команда.ЗначениеАргумента("PATH");
	Если НРег(Лев(Путь, СтрДлина(АдресСайта))) <> НРег(АдресСайта)
		И НРег(Лев(Путь, 4)) <> "http" Тогда
		Если Лев(Путь, 1) <> "/" Тогда
			Путь = АдресСайта + "/" + Путь;
		Иначе
			Путь = АдресСайта + Путь;
		КонецЕсли;
	КонецЕсли;

	Логин = Команда.ЗначениеОпции("login");
	Пароль = Команда.ЗначениеОпции("password");

	Сессия = Новый СоединениеССайтом(АдресСайта, Логин, Пароль);	
	
	ПутьСохранения = Команда.ЗначениеОпции("out");
	Сессия.УстановитьПутьСохранения(ПутьСохранения);

	СохранитьПринудительно = Команда.ЗначениеОпции("force");

	Результат = Сессия.ПолучитьСодержимое(Путь);
	Если НЕ Результат.ЭтоФайл Тогда
		
		Если СохранитьПринудительно Тогда
			Служебный.СохранитьТекстВФайл(Результат.ТекстСтраницы, ПутьСохранения);	
			Сообщить(СтрШаблон("Сохранен файл %1" + Символы.ПС, ПутьСохранения));
		Иначе
			Выражение = ШаблоныСтраниц.ВыражениеСсылкиНаСкачивание();
			Совпадения = Служебный.СовпаденияВТексте(Результат.ТекстСтраницы, Выражение);
			Если НЕ Совпадения.Количество() Тогда
				ТекстОшибки = "Неверно задан URL " + Путь + "
							|Ссылка не указывает на файл.
							|Для принудительного скачивания страницы как файла используйте опцию '--force'";
				ВызватьИсключение ТекстОшибки;
			КонецЕсли;
			
			СсылкаСкачивания = Совпадения[0].Группы[1].Значение;
			Результат = Сессия.ПолучитьСодержимое(СсылкаСкачивания);
			Если НЕ Результат.ЭтоФайл Тогда
				ВызватьИсключение "Неверно определен URL " + СсылкаСкачивания;
			КонецЕсли;	
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры