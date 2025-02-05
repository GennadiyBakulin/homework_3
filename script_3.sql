--Скрипт №3 - Разделение ответственности.
--Менеджеры компаний, должны видеть только заявки компаний.
--Создать view которая отображает только заявки компаний

do
$$
    begin
--         drop view request_company;
        create view request_company as
        (
        select *
        from bid
        where is_company
            );
    end;
$$