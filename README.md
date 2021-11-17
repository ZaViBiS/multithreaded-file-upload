![Ofile](https://i.imgur.com/7SUZLnH.png)


*ofile - это консольная утелита для загрузки файлов в несколько потоков [2; ∞)*

* -x           количество потоков
* -t           количество повторений при ошибке (100)
* -h, --help   флаги и информация про них
* -o, --output имя выходного фала (если не указан будет взят из url'а)
* -m           убрать ограничение на размер файла

*P.S. не советую ставить слишком много потоков т.к. это только замндлит загрузку*

*Файлы больше 3 GB не поддерживаются т.к. файл скачивается в ОЗУ*

### build
*можно скачать уже собраный [тут](https://github.com/vlang/v/releases)*

*зависемости для сборки не знаю*

```bash
git clone https://github.com/vlang/v
cd v
make
```
*установка библиотеки для сборки*
```bash
v install nedpals.vargs
```
*теперь периходим к сборке самого пакета (лутше скачайте [исходный коди](https://github.com/ZaViBiS/multithreaded-file-upload/releases) из релиза, а не через git)*
```bash
v -enable-globals main.v
```
*на выходе получаем бинарный файл готовый к роботе*