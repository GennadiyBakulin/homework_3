--Скрипт №1 - Распределение заявок по продуктовым таблицам
--Создать скрипт, который будет:
--1. Создавать таблицы на основании таблицы bid:
--Имя таблицы должно быть основано на типе продукта + является ли он компанией
--Если такая таблица уже есть, скрипт не должен падать!
--Например:
--для записи где product_type = credit, is_company = false будет создана таблица:
--person_credit, с колонками: id (новый id), client_name, amount
--для записи где product_type = credit, is_company = true:
--company_credit, с колонками: id (новый id), client_name, amount
--2. Копировать заявки в соответствующие таблицы c помощью конструкции:
--2.1 Для вставки значений можно использовать конструкцию
--insert into (col1, col2)
--select col1, col2
--from [наименование таблицы]
--2.2 Для исполнения динамического запроса с параметрами можно использовать конструкцию
--execute '[текст запроса]' using [значение параметра №1], [значение параметра №2].
--Пример:
--execute 'select * from product where product_type = $1 and is_company = $2' using 'credit', false;

do
$$
    declare
        result_row record;
        table_name varchar;
    begin
        for result_row in (select product_type, is_company from bid group by product_type, is_company)
            loop
                if result_row.is_company then
                    table_name := 'company_' || result_row.product_type;
                else
                    table_name := 'person_' || result_row.product_type;
                end if;
                execute
                    format(
                            'create table %I
                            (
                            id serial primary key,
                            client_name varchar(50) not null,
                            amount numeric not null
                            )',
                            table_name);

                execute
                    'insert into ' || table_name || '(client_name, amount)
                     select client_name, amount
                     from bid
                     where product_type = ' || quote_literal(result_row.product_type) ||
                    ' and is_company = ' || result_row.is_company;
            end loop;
    end;
$$
