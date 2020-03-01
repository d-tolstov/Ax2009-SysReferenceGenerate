## Ax2009 SysReferenceGenerate
Generate references to Wcf and Web API services

В Ax2009 есть штатный механизм создания референсов для Wcf-сервисов (References).  
У него есть следующие минусы :
- генерит невалидные референсы после установки проекта [Ax2009-NetFramework4-Support](https://github.com/d-tolstov/Ax2009-NetFramework4-Support)
- нельзя вызывать веб-сервисы с basic-аутентификацией
- нельзя задавать в программном коде динамические URL для референсов
- нельзя задавать в программном коде настройки биндинга (`maxReceivedMessageSize`, `maxNameTableCharCount` и т.д.). Их можно настраивать только в `app.config`, но после каждой регенерации референса `app.config` обновляется заново.
- генерит референсы только на Wcf-сервисы

Поэтому было решено переделать штатный механизм генерации референсов.  
Основные цели :
- убрать все перечисленные минусы
- добавить генерацию референсов для Web API
- оставить штатный диалог создания референсов (чтобы внешне для пользователей, обновляющих референсы, ничего не изменилось)

### Wcf
За основу был взят простой алгоритм :
- генерация файла `namespace.cs` прокси-класса с помощью утилиты `svcutil.exe`.
- генерация из файла `namespace.cs` файла `namespace.dll` с помощью утилиты `csc.exe` (компилятор).

Все шаги происходят на стороне АОСа. АОСу нужно дать информацию о местонахождении утилит.  
Реализовано это с помощью параметров в конфиг-файле :
```
    <SysReferenceGenerate_Wcf>
        <enable>true</enable>
        <svcutil_path>здесь задаётся путь к утилите SvcUtil.exe</svcutil_path>
        <csc_path>C:\Windows\Microsoft.NET\Framework\v3.5\csc.exe</csc_path>
    </SysReferenceGenerate_Wcf>
```
Утилита `csc.exe` используется штатная, из папки `.NET Framework 3.5` ОС Windows.  
А утилита `SvcUtil.exe` не является штатной для ОС Windows. Она относится к `Windows SDK`. В нашем случае нужна утилита из `Windows SDK` версии `6.0`. Находим утилиту, помещаем в какой-нибудь каталог, доступный АОСу. Указываем путь в параметрах конфиг-файла.

### Web API
В случае с Web API за основу был взят алгоритм формирования прокси-классов с помощью [NSwagStudio](https://github.com/RicoSuter/NSwag/wiki/NSwagStudio).  
- генерация файла `namespace.cs` прокси-класса с помощью утилиты `nswag.exe`, подавая на входе ссылку на спецификацию swagger.
- генерация из файла `namespace.cs` файла `namespace.dll` с помощью утилиты `csc.exe` (компилятор).

Программа `NSwagStudio` должна быть установлена на сервере АОСа.  
У программы `NSwagStudio` есть следующие известные нюансы :
- функции WebAPI не должны содержать [символы подчёркивания "`_`" (underscore)](https://github.com/RicoSuter/NSwag/issues/1222). Иначе программный код C# сгенерится некорректно.

Воспользоваться штатной утилитой `csc.exe` в данном случае не получилось. Утилита вместе с сопутствующими `dll` была скопирована в отдельную папку. Обращение к утилите `csc.exe` происходит посредством скрипта `generate-dll.bat`. В одном каталоге со скриптом должен находиться каталог `csc`.  
Все шаги происходят на стороне АОСа. АОСу нужно дать информацию о местонахождении утилиты и скрипта.  
Реализовано это с помощью параметров в конфиг-файле :
```
    <SysReferenceGenerate_NSwag>
        <enable>true</enable>
        <nswag_path>C:\Program Files (x86)\Rico Suter\NSwagStudio\Win\nswag.exe</nswag_path>
        <generate_dll_path>здесь задаётся путь к скрипту generate-dll.bat</generate_dll_path>
    </SysReferenceGenerate_NSwag>
```
Формировать референсы на Web API можно только с установленным проектом [Ax2009-NetFramework4-Support](https://github.com/d-tolstov/Ax2009-NetFramework4-Support).

### Один и тот же диалог
В обоих случаях используется один и тот же диалог создания референса, но в поле `URL-адрес WSDL` указываем URL-ссылку либо на спецификацию WSDL либо на спецификацию swagger.  
В данный момент функционал отделяет URL одного типа от URL другого типа семантически. Все URL, заканчивающиеся на :
- .svc
- .asmx
- wsdl

являются ссылками на Wcf-сервисы. Всё остальное система воспринимает как ссылку на спецификацию swagger.

### Вызов референсов из программного кода


### Зависимости от других репозиториев :
- [SysFile](https://github.com/d-tolstov/Ax2009-SysFile)
- [SysConfigFile](https://github.com/mazzy-ax/SysConfigFile)
- [Ax2009-NetFramework4-Support](https://github.com/d-tolstov/Ax2009-NetFramework4-Support)