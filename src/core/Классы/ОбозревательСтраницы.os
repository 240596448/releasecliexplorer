#Использовать coloratos

Перем Сессия;
Перем АдресСтраницы;
Перем ТаблицаДействий;

Перем ДействиеВыхода;
Перем РазмерСтраницы;
Перем ТекстСтраницы;

Перем Параметры;

Процедура ПриСозданииОбъекта(
		Знач ПарамСессия,
		Знач ПарамАдресСтраницы,
		Знач ПарамРазмерСтраницы,
		Знач ДополнительныеПараметры) 
	
	Сессия				= ПарамСессия;
	АдресСтраницы		= ПарамАдресСтраницы;
	РазмерСтраницы		= ПарамРазмерСтраницы;

	Параметры = Новый Структура();
	Параметры.Вставить("НомерСтраницы", 1);
	Параметры.Вставить("ЭтоПерваяСтраница", Ложь);
	Параметры.Вставить("ЗаменыВШаблоне", Неопределено);
	ЗаполнитьЗначенияСвойств(Параметры, ДополнительныеПараметры);

	ИнициализацияТаблицыДействий();
	
	ПросмотрСтраницы();
	
КонецПроцедуры

Процедура ИнициализацияТаблицыДействий()
	
	ТаблицаДействий = Новый ТаблицаЗначений();
	ТаблицаДействий.Колонки.Добавить("КодОперации");
	ТаблицаДействий.Колонки.Добавить("Адрес");
	ТаблицаДействий.Колонки.Добавить("Описание");
	ТаблицаДействий.Колонки.Добавить("Действие");
	ТаблицаДействий.Колонки.Добавить("Параметры");
	ТаблицаДействий.Колонки.Добавить("ЦветТекста");
	
КонецПроцедуры

Процедура ПросмотрСтраницы()
	
	ЦветнойВывод.ВывестиСтроку("получаю данные с сайта ...", "Серый");

	Результат = Сессия.ПолучитьСодержимое(АдресСтраницы);
	Если Результат.ЭтоФайл Тогда
		ДействиеВыхода = "Скачивание";
		Возврат;
	КонецЕсли;

	ТекстСтраницы = Результат.ТекстСтраницы;

	ВывестиПорцию();
	
КонецПроцедуры

Процедура ВывестиПорцию(Старт = 0) Экспорт
	
	Консоль.Очистить();
	ЦветнойВывод.ВывестиСтроку("(Адрес:|#color=Белый) " + АдресСтраницы, "Желтый");

	ЗаполнитьТаблицу(Старт);
	
	ВывестиТаблицу();
	
	ОжидатьВыбор();

КонецПроцедуры

Процедура ЗаполнитьТаблицу(Старт)
	
	МассивСтраниц = ШаблоныСтраниц.МассивСтраниц();
	
	Для НомерСтраницы = Параметры.НомерСтраницы По МассивСтраниц.ВГраница() Цикл
		Выражение = МассивСтраниц[НомерСтраницы-1];
		
		Если Параметры.ЗаменыВШаблоне <> Неопределено Тогда
			Для Каждого кзЗамены Из Параметры.ЗаменыВШаблоне Цикл
				Выражение = СтрЗаменить(Выражение, кзЗамены.Ключ, кзЗамены.Значение);
			КонецЦикла;
		КонецЕсли;

		Совпадения = Служебный.СовпаденияВТексте(ТекстСтраницы, Выражение);
		Если Совпадения.Количество() Тогда
			Прервать;
		КонецЕсли;	
	КонецЦикла;
	
	Нумератор = 0;
	СтрокаПредыдущие = Ложь;
	ТаблицаДействий.Очистить();
	
	Для Каждого Совпадение Из Совпадения Цикл
		
		Нумератор = Нумератор + 1;
		Если Старт > Нумератор Тогда
			Если НЕ СтрокаПредыдущие Тогда
				СтрокаПредыдущие = Истина;
				стрДействие = ТаблицаДействий.Добавить();
				стрДействие.КодОперации = "Q";
				стрДействие.Описание = СтрШаблон("<< Предыдущие (%1)", РазмерСтраницы);
				стрДействие.Действие = "ВывестиПорцию";				
				стрДействие.Параметры = Служебный.ВМассиве(Старт - РазмерСтраницы);	
				стрДействие.ЦветТекста = "Серый";				
			КонецЕсли;
			Продолжить;
		КонецЕсли;
		
		Группы = Совпадение.Группы;
		Если Группы.Количество() < 2 Тогда
			Продолжить;
		КонецЕсли;
		
		Описание = Новый Массив;
		Для инд = 2 По Группы.Количество() - 1 Цикл
			Если ЗначениеЗаполнено(Группы[инд].Значение) Тогда
				Описание.Добавить(Группы[инд].Значение);
			КонецЕсли;
		КонецЦикла;
		
		ДополнительныеПараметры = Новый Структура("НомерСтраницы", НомерСтраницы + 1);	
		Если НомерСтраницы = 1 Тогда
			Адрес = "/total";
			соотв = Новый Соответствие;
			соотв.Вставить("%Раздел%", Группы[1].Значение);
			ДополнительныеПараметры.Вставить("ЗаменыВШаблоне", соотв);	
		Иначе
			Адрес = Группы[1].Значение;
		КонецЕсли;
		
		стрДействие = ТаблицаДействий.Добавить();
		стрДействие.КодОперации = Строка(Нумератор);
		стрДействие.Адрес = Адрес;
		стрДействие.Описание = СтрСоединить(Описание, " / ");
		стрДействие.Действие = "ПереходНаСтраницу";
		стрДействие.Параметры = Служебный.ВМассиве(Адрес, ДополнительныеПараметры);
		стрДействие.ЦветТекста = "Белый";				
		
		Если Совпадения.Количество() - Нумератор > 0
			И (ТаблицаДействий.Количество() - СтрокаПредыдущие) >= РазмерСтраницы Тогда
			стрДействие = ТаблицаДействий.Добавить();
			стрДействие.КодОперации = "W";
			СледующаяПорция = Мин(РазмерСтраницы, Совпадения.Количество()-Нумератор);
			стрДействие.Описание = СтрШаблон("Следующие (%1) >>", СледующаяПорция);
			стрДействие.Действие = "ВывестиПорцию";				
			стрДействие.Параметры = Служебный.ВМассиве(Нумератор + 1);
			стрДействие.ЦветТекста = "Серый";				
			Прервать;	
		КонецЕсли;
			
	КонецЦикла;

	НештатнаяСитуация = Ложь;
	Если Совпадения.Количество() = 0 Тогда
		ВыражениеОшибка = ШаблоныСтраниц.ВыражениеОшибка(); // ошибка сервера
		Совпадения = Служебный.СовпаденияВТексте(ТекстСтраницы, ВыражениеОшибка);
		Если Совпадения.Количество() Тогда
			Группы = Совпадения[0].Группы;
			Если Группы.Количество() > 1 Тогда
				НештатнаяСитуация = Истина;
				ЦветнойВывод.ВывестиСтроку(Группы[1].Значение, "Малиновый");
			КонецЕсли;			
		КонецЕсли;			
	КонецЕсли;
		
	стрДействие = ТаблицаДействий.Добавить();
	стрДействие.КодОперации = "Z";
	стрДействие.ЦветТекста = "Серый";				
	Если Параметры.ЭтоПерваяСтраница Или НештатнаяСитуация И Старт = 0 Тогда
		стрДействие.Описание = "Завершить работу";
		стрДействие.Действие = "Выход";
	Иначе
		стрДействие.Описание = "Назад";
		стрДействие.Действие = "Назад";
	КонецЕсли;

КонецПроцедуры

Процедура ВывестиТаблицу()
	
	Для Каждого стрДействие Из ТаблицаДействий Цикл
		ЦветнойВывод.ВывестиСтроку(СтрШаблон("[ (%1|#color=Желтый) ] - %2", стрДействие.КодОперации, стрДействие.Описание), стрДействие.ЦветТекста);	
	КонецЦикла;
	
КонецПроцедуры

Процедура ОжидатьВыбор(Сообщение = "Выберите действие: ")
	
	ВыбранныйКод = "";
	
	ПредыдущееЗначениеЦветаТекта = Консоль.ЦветТекста;
	Если НЕ ЗначениеЗаполнено(ПредыдущееЗначениеЦветаТекта) Тогда
		ПредыдущееЗначениеЦветаТекта = ЦветКонсоли.Белый;
	КонецЕсли;
	
	ЦветнойВывод.Вывести(Сообщение, "Бирюза");
	Консоль.ЦветТекста = ЦветКонсоли.Желтый;

	ВыбранныйКод = Консоль.ПрочитатьСтроку();
	Консоль.ЦветТекста = ПредыдущееЗначениеЦветаТекта;
	
	ВыбраннаяСтрока = ТаблицаДействий.Найти(ВРег(ВыбранныйКод), "КодОперации");
	Если ВыбраннаяСтрока = Неопределено Тогда
		ОжидатьВыбор("Не найдена операция. Повторите выбор: ");
	Иначе
		Рефлектор = Новый Рефлектор();
		Рефлектор.ВызватьМетод(ЭтотОбъект, ВыбраннаяСтрока.Действие, ВыбраннаяСтрока.Параметры);
	КонецЕсли;
	
КонецПроцедуры

Процедура Назад() Экспорт
	ДействиеВыхода = "Назад";
КонецПроцедуры

Процедура Выход() Экспорт
	ДействиеВыхода = "Выход";
КонецПроцедуры

Процедура ПереходНаСтраницу(Адрес, ДополнительныеПараметры) Экспорт
	
	ОбзревательСледующейСтраницы = Новый ОбозревательСтраницы(Сессия, Адрес, РазмерСтраницы, ДополнительныеПараметры);
	Если ОбзревательСледующейСтраницы.ДействиеВыхода() = "Назад" Тогда
		ПросмотрСтраницы();
	ИначеЕсли ОбзревательСледующейСтраницы.ДействиеВыхода() = "Скачивание" Тогда
		ОжидатьВыбор();
	КонецЕсли;
	
	ОсвободитьОбъект(ОбзревательСледующейСтраницы);

КонецПроцедуры

Функция ДействиеВыхода() Экспорт
	Возврат ДействиеВыхода;
КонецФункции
