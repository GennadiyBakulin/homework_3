--Скрипт №2 - Начисление процентов по кредитам за день
--Создать скрипт, который:
--1. Создаст(если нет) таблицу credit_percent для начисления процентов по кредитам: имя клиента, сумма начисленных процентов
--2. Имеет переменную - базовая кредитная ставка со значением "0.1"
--3. Возьмет значения из таблиц person_credit и company_credit и вставит их в credit_percent:
-- необходимо выбрать id клиента и (сумму кредита * базовую ставку) / 365 для компаний
-- необходимо выбрать id клиента и (сумму кредита * (базовую ставку + 0.05) / 365 для физ лиц
--4. Печатает на экран общую сумму начисленных процентов в таблице

do
$$
    declare
        basic_credit_rate    numeric := 0.1;
        add_percent          numeric := 0.05;
        period_in_days       int     := 365;
        total_amount_percent numeric;
        current_row          record;
    begin
        create table if not exists credit_percent
        (
            id             serial primary key,
            client_name    varchar(50) not null,
            amount_percent numeric     not null
        );

        for current_row in (select client_name, amount from company_credit)
            loop
                insert into credit_percent (client_name, amount_percent)
                VALUES (current_row.client_name,
                        round(current_row.amount * basic_credit_rate / period_in_days, 2));
            end loop;

        for current_row in (select client_name, amount from person_credit)
            loop
                insert into credit_percent (client_name, amount_percent)
                VALUES (current_row.client_name,
                        round(current_row.amount * (basic_credit_rate + add_percent) / period_in_days, 2));
            end loop;

        total_amount_percent := (select sum(amount_percent) from credit_percent);
        raise notice 'Общая сумма начисленных процентов равна %', total_amount_percent;
    end;
$$