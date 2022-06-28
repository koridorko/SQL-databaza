-- author: xrajko00 <xrajko00@stud.fit.vutbr.cz>
--         xgajdo30 <xgajdo30@stud.fit.vutbr.cz>
--
-- Riesenie zodpoveda opravenemu ER-diagramu po 1. termine odovzdania

drop table Vazen cascade constraints;
drop table Cela cascade constraints;
drop table Vaznica cascade constraints;
drop table Zmena cascade constraints;
drop table Dozorca cascade constraints;
drop table Paserak cascade constraints;
drop table Objednavka cascade constraints;
drop table Pecivo cascade constraints;
drop table Zamestnanec_pekarne cascade constraints;
drop table Surovina cascade constraints;
drop table Obsahuje cascade constraints;
drop table Dozorca_pracuje cascade constraints;
drop table Paserak_pasuje cascade constraints;
drop table Objednavku_vybavuje cascade constraints;
drop table Pecie_pecivo cascade constraints;
drop table Pecivo_obsahuje cascade constraints;

drop sequence "vazen-id";

drop MATERIALIZED VIEW "Vazni-pocet-objednavok";

create table Vazen(
    ID_vazna int default null primary key,
    meno varchar(255) not null,
    datum_narodenia date not null,
    e_mail varchar(255) not null,
    platobne_udaje varchar(255) not null check (regexp_like(platobne_udaje, '^(([0-9]{1,6})-)?([0-9]{2,10})/([0-9]{4})$')),
    ID_cely int
);

-- pocet lozok (zmena oproti ER)
create table Cela(
    ID_cely int primary key,
    pocet_lozok int not null,
    ID_vaznice int
);

create table Vaznica(
    ID_vaznice int primary key,
    nazov varchar(255) not null,
    adresa varchar(255) not null
);

create table Zmena(
    ID_zmeny int primary key,
    cas_nastupu timestamp not null,
    cas_ukoncenia timestamp not null,
    ID_vaznice int
);

create table Dozorca(
    ID_dozorcu int primary key,
    meno varchar(255) not null,
    adresa varchar(255),
    e_mail varchar(255) not null
);

create table Paserak(
    ID_paseraka int primary key,
    meno varchar(255) not null,
    adresa varchar(255),
    e_mail varchar(255) not null,
    ID_dozorcu int
);

create table Objednavka(
    ID_objednavky int primary key,
    zapeceny_predmet varchar(255),
    datum_vytvorenia timestamp not null,
    stav varchar(255) not null,
    termin_dodania timestamp,
    sposob_dodania varchar(255),
    ID_vazna int,
    ID_paseraka int
);

create table Pecivo(
    ID_peciva int primary key,
    nazov varchar(255) not null,
    druh varchar(255) not null,
    alergeny varchar(255),
    hmotnost float check(hmotnost > 0),
    recept varchar(255) not null,
    cena float check(cena > 0),
    bezlepkovost number(1) check (bezlepkovost between 0 and 1)
);

create table Zamestnanec_pekarne(
    ID_zamestnanca int primary key,
    meno varchar(255) not null,
    adresa varchar(255),
    e_mail varchar(255) not null
);

create table Surovina(
    ID_suroviny int primary key,
    nazov varchar(255) not null,
    cena float check(cena > 0),
    datum_dodania date,
    mnozstvo_na_sklade int check(mnozstvo_na_sklade >= 0)
);

create table Obsahuje(
    ID_objednavky int not null,
    ID_peciva int not null,
    mnozstvo int check(mnozstvo > 0)
);

create table Dozorca_pracuje(
    ID_zmeny int not null,
    ID_dozorcu int not null
);

create table Paserak_pasuje(
    ID_vaznice int not null,
    ID_paseraka int not null
);

create table Objednavku_vybavuje(
    ID_objednavky int not null,
    ID_zamestnanca int not null
);

create table Pecie_pecivo(
    ID_peciva int not null,
    ID_zamestnanca int not null
);

create table Pecivo_obsahuje(
    ID_peciva int not null,
    ID_suroviny int not null
);

-- Vazen byva v cele
alter table Vazen
    add constraint FK_byva foreign key (ID_cely) references Cela(ID_cely) on delete cascade;

-- Cela sa nachadza vo vaznici
alter table Cela
    add constraint FK_nachadza_sa foreign key (ID_vaznice) references  Vaznica(ID_vaznice) on delete cascade;

-- Zmena prebieha vo vaznici
alter table Zmena
    add constraint FK_prebieha_v foreign key (ID_vaznice) references Vaznica(ID_vaznice) on delete cascade;

-- Dozorca pracuje v zmenach
alter table Dozorca_pracuje
    add constraint PK_dozorca primary key (ID_dozorcu, ID_zmeny)
    add constraint FK_pracuje_v_zmene foreign key (ID_dozorcu) references Dozorca(ID_dozorcu)
    add constraint FK_pracuju_dozorcovia foreign key (ID_zmeny) references Zmena(ID_zmeny);

-- Dozorca je dohodnuty
alter table Paserak
    add constraint FK_je_dohodnuty foreign key (ID_dozorcu) references Dozorca(ID_dozorcu) on delete cascade;

-- Paserak pasuje do vaznice
alter table Paserak_pasuje
    add constraint PK_paserak primary key (ID_paseraka, ID_vaznice)
    add constraint FK_pasuje_do_vaznice foreign key (ID_paseraka) references Paserak(ID_paseraka)
    add constraint FK_pasuju_paseraci foreign key (ID_vaznice) references Vaznica(ID_vaznice);

-- Paserak prebera objenavku
alter table Objednavka
    add constraint FK_prebera foreign key (ID_paseraka) references Paserak(ID_paseraka) on delete cascade;

-- Vazen objednal objednavku
alter table Objednavka
    add constraint FK_objednal foreign key (ID_vazna) references Vazen(ID_vazna) on delete cascade;

-- Objednavka obsahuje
alter table Obsahuje
    add constraint PK_obsahuje primary key (ID_objednavky, ID_peciva)
    add constraint FK_objednavka_obsahuje foreign key (ID_objednavky) references Objednavka(ID_objednavky)
    add constraint FK_pecivo_obsahuje foreign key (ID_peciva) references Pecivo(ID_peciva);

-- Zamestnanec vybavuje objadnavku
alter table Objednavku_vybavuje
    add constraint PK_vybavuje primary key (ID_objednavky, ID_zamestnanca)
    add constraint FK_objednavku_vybavuje foreign key (ID_objednavky) references Objednavka(ID_objednavky)
    add constraint FK_zamestnanec_vybavuje foreign key (ID_zamestnanca) references Zamestnanec_pekarne(ID_zamestnanca);

-- Zamestnanec pecie pecivo
alter table Pecie_pecivo
    add constraint PK_pecie primary key (ID_zamestnanca, ID_peciva)
    add constraint FK_pecivo_pecie foreign key (ID_peciva) references Pecivo(ID_peciva)
    add constraint FK_zamestnanec_pecie foreign key (ID_zamestnanca) references Zamestnanec_pekarne(ID_zamestnanca);

-- Pecivo obsahuje suroviny
alter table Pecivo_obsahuje
    add constraint PK_obsahuje_surovinu primary key (ID_peciva, ID_suroviny)
    add constraint FK_pecivo_obsahuje_surovinu foreign key (ID_peciva) references Pecivo(ID_peciva)
    add constraint FK_surovina_v_pecive foreign key (ID_suroviny) references Surovina(ID_suroviny);


--- Trigger pre generovanie ID_vazna zo sekvencie, pokial nieje ID_vazna zadane
CREATE SEQUENCE "vazen-id";
CREATE OR REPLACE TRIGGER "vazen-id-generator"
	BEFORE INSERT ON Vazen
	FOR EACH ROW
BEGIN
	IF :NEW.ID_vazna IS NULL THEN
		:NEW.ID_vazna := "vazen-id".NEXTVAL;
	END IF;
END;
/

-- Trigger pre priradnie alergenu v pripade lepkovosti peciva
CREATE OR REPLACE TRIGGER "pridaj-lepok" BEFORE INSERT ON Pecivo FOR EACH ROW
BEGIN
    IF :NEW.bezlepkovost = 1 THEN
        :NEW.alergeny := 'lepok';
    END IF;
END;
/

CREATE OR REPLACE PROCEDURE zdrazenie
    ("zdraz" Pecivo.cena%TYPE)
AS BEGIN
    update Pecivo set cena = cena + "zdraz";
END;
/

CREATE OR REPLACE PROCEDURE kontrola
    ("ID_cely" NUMBER)
AS
    "cela_pocet_fetch" Cela.pocet_lozok%TYPE;
    "cela_lozok_fetch" Cela.pocet_lozok%TYPE;

    CURSOR "cela_pocet" IS SELECT COUNT(*) FROM Vazen WHERE ID_cely = "ID_cely" GROUP BY ID_cely;
    CURSOR "max_cela_lozok" IS SELECT pocet_lozok FROM Cela WHERE ID_cely = "ID_cely";
BEGIN
    OPEN "cela_pocet";
    OPEN "max_cela_lozok";
    FETCH "cela_pocet" INTO "cela_pocet_fetch";
    FETCH "max_cela_lozok" INTO "cela_lozok_fetch";

    IF "cela_pocet_fetch" >= "cela_lozok_fetch" THEN
        DBMS_OUTPUT.PUT_LINE('V cele nie je dostatok miesta! Max kapacita: ' || "cela_pocet_fetch");
    END IF;

    CLOSE "cela_pocet";
    CLOSE "max_cela_lozok";

    EXCEPTION WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Vyskytla sa necakana chyba!');

END;
/


insert into Vaznica values(3275, 'Alkatraz', '"615-9452 Orci, Ave"');
insert into Cela values(4632, 3, 3275);
insert into Vazen values(2335, 'Riley Cooley', TO_DATE('1984/07/14', 'yyyy/mm/dd'),  'morbi.vehicula.pellentesque@google.couk', '9685-4165872456/6847', 4632);
insert into Cela values(3445, 1, 3275);
insert into Vazen values(3047, 'Mannix Stanton', TO_DATE('1959/07/05', 'yyyy/mm/dd'),  'suspendisse.non.leo@aol.edu', '721201/8862', 3445);
insert into Zmena values(2432, TO_TIMESTAMP('06:13:49', 'HH24:MI:SS'), TO_TIMESTAMP('08:30:30', 'HH24:MI:SS'), 3275);
insert into Dozorca values(3218, 'Aladdin Williamson',  '634-4750 Natoque Avenue',  'lorem@hotmail.edu');
insert into Dozorca_pracuje values(2432, 3218);
insert into Dozorca values(3784, 'Basia Holder',  '"452-345 Orci, Street"',  'primis.in.faucibus@protonmail.couk');
insert into Dozorca_pracuje values(2432, 3784);
insert into Dozorca values(4319, 'Tashya Steele',  'Ap #152-1883 Amet Rd.',  'ut.erat@google.org');
insert into Dozorca_pracuje values(2432, 4319);
insert into Dozorca values(484, 'Sophia Cardenas',  '"615-9452 Orci, Ave"',  'aliquet@protonmail.net');
insert into Dozorca_pracuje values(2432, 484);
insert into Dozorca values(982, 'Zenaida Jefferson',  'Ap #993-4681 Neque. Ave',  'molestie.in@yahoo.edu');
insert into Dozorca_pracuje values(2432, 982);
insert into Zmena values(4846, TO_TIMESTAMP('05:29:14', 'HH24:MI:SS'), TO_TIMESTAMP('09:43:23', 'HH24:MI:SS'), 3275);
insert into Dozorca values(2271, 'Risa Shaffer',  '699-2356 Aenean Ave',  'sit.amet@icloud.org');
insert into Dozorca_pracuje values(4846, 2271);
insert into Vaznica values(4350, 'FIT', 'Ap #675-1566 Tempor Av.');
insert into Cela values(2107, 3, 4350);

-- ID generovane pomocou triggeru "vazen-id-generator"
insert into Vazen values(null, 'Theodore Sutton', TO_DATE('1977/08/22', 'yyyy/mm/dd'),  'amet.diam.eu@hotmail.net', '672-666/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'martin.garix@gmail.com', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'marsdcatin.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'mardscatin.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'marticadsn.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'martdcadsin.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'martiner.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'martidszdxcveran.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'marticn.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'marticdsn.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'marvdcearcvaervtin.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'marticdsacasn.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'martdsacasccsdin.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'martcadscain.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'martiadscacn.garix@gmail.edu', '672-6665416/2417', 2107);
insert into Vazen values(null, 'Martin Garrix', TO_DATE('1996/08/22', 'yyyy/mm/dd'),  'martadscacdsin.garix@gmail.edu', '672-6665416/2417', 2107);


insert into Zmena values(531, TO_TIMESTAMP('04:04:50', 'HH24:MI:SS'), TO_TIMESTAMP('11:57:14', 'HH24:MI:SS'), 4350);
insert into Dozorca values(2184, 'Melodie Hart',  '666-2549 Tortor. Rd.',  'sem.pellentesque.ut@outlook.ca');
insert into Dozorca_pracuje values(531, 2184);
insert into Dozorca values(1931, 'Hayes Mcintosh',  '877-3011 Neque Street',  'urna@google.net');
insert into Dozorca_pracuje values(531, 1931);


insert into Paserak values(2252, 'Yoshi Mcgowan',  'Ap #625-6205 Lacus. Rd.',  'ante.nunc@google.net', 2184);
insert into Paserak values(244, 'Frances Williams',  '"289-3810 Dui, St."',  'nascetur.ridiculus@icloud.edu', 1931);
insert into Paserak values(2952, 'Brennan Tillman',  '457-8960 Non Av.',  'egestas.lacinia@google.net', 2271);
insert into Paserak values(3498, 'Aimee Good',  'Ap #843-594 Euismod St.',  'suspendisse.eleifend@aol.ca', 3784);


insert into Objednavka values(1789, null, CURRENT_TIMESTAMP, 'balenie', CURRENT_TIMESTAMP + interval '2' day, 'letecky', 3047, 2252);
insert into Objednavka values(4028, null, CURRENT_TIMESTAMP, 'balenie', CURRENT_TIMESTAMP + interval '2' day, 'letecky', 3047, 2252);
insert into Objednavka values(3002, 'Nozik', CURRENT_TIMESTAMP, 'balenie', CURRENT_TIMESTAMP + interval '2' day, 'letecky', 2335, 2952);
insert into Objednavka values(2190, 'Nozik', CURRENT_TIMESTAMP, 'balenie', CURRENT_TIMESTAMP + interval '2' day, 'letecky', 2335, 3498);
insert into Objednavka values(4430, 'Nozik', CURRENT_TIMESTAMP, 'balenie', CURRENT_TIMESTAMP + interval '2' day, 'letecky', 3047, 2252);
insert into Objednavka values(3348, 'Nozik', CURRENT_TIMESTAMP, 'balenie', CURRENT_TIMESTAMP + interval '2' day, 'letecky', 3047, 244);
insert into Objednavka values(4486, 'Nozik', CURRENT_TIMESTAMP, 'balenie', CURRENT_TIMESTAMP + interval '2' day, 'letecky', 2335, 3498);


insert into Pecivo values(3767, 'Semla', 'slane', 'null', 0.96, 'babickin', 2.94, 1);
insert into Pecivo values(3287, 'Briouat', 'slane', 'null', 0.45, 'babickin', 1.97, 0);
insert into Pecivo values(1941, 'Karakudamono', 'slane', 'null', 0.31, 'babickin', 2.21, 1);
insert into Pecivo values(147, 'Stutenkerl', 'slane', 'null', 0.89, 'babickin', 0.67, 1);
insert into Pecivo values(3612, 'Conversation', 'sladke', 'null', 0.46, 'babickin', 1.06, 0);
insert into Pecivo values(1150, 'Banbury cake', 'sladke', 'null', 0.56, 'babickin', 0.95, 0);
insert into Pecivo values(579, 'Poppy seed roll', 'sladke', 'null', 0.17, 'babickin', 2.71, 1);
insert into Pecivo values(1521, 'Rollò', 'sladke', 'null', 0.56, 'babickin', 2.1, 0);
insert into Pecivo values(2724, 'Flaky pastry', 'slane', 'null', 0.63, 'babickin', 2.29, 0);


insert into Surovina values(4207, 'Voda', 0.17, CURRENT_TIMESTAMP, 81);
insert into Surovina values(3634, 'Muka', 0.39, CURRENT_TIMESTAMP, 8);
insert into Surovina values(625, 'Syr', 0.31, CURRENT_TIMESTAMP, 99);
insert into Surovina values(4272, 'Drozdie', 0.36, CURRENT_TIMESTAMP, 88);
insert into Surovina values(1595, 'Nozik', 0.33, CURRENT_TIMESTAMP, 55);


insert into Pecivo_obsahuje values(1941, 625);
insert into Pecivo_obsahuje values(1941, 4207);
insert into Pecivo_obsahuje values(579, 4207);
insert into Pecivo_obsahuje values(579, 3634);
insert into Pecivo_obsahuje values(3767, 4272);
insert into Pecivo_obsahuje values(3767, 1595);
insert into Pecivo_obsahuje values(3767, 4207);
insert into Pecivo_obsahuje values(2724, 1595);
insert into Pecivo_obsahuje values(2724, 625);
insert into Pecivo_obsahuje values(147, 4272);
insert into Pecivo_obsahuje values(3287, 1595);
insert into Pecivo_obsahuje values(3287, 625);
insert into Pecivo_obsahuje values(1521, 3634);
insert into Pecivo_obsahuje values(1521, 625);
insert into Pecivo_obsahuje values(1521, 4207);
insert into Pecivo_obsahuje values(1150, 3634);
insert into Pecivo_obsahuje values(3612, 4272);
insert into Pecivo_obsahuje values(3612, 1595);
insert into Pecivo_obsahuje values(3612, 3634);


insert into Obsahuje values(4028, 3612, 20);
insert into Obsahuje values(1789, 3287, 20);
insert into Obsahuje values(2190, 147, 4);
insert into Obsahuje values(3348, 3287, 1);
insert into Obsahuje values(4486, 1941, 18);
insert into Obsahuje values(4430, 1150, 20);
insert into Obsahuje values(3002, 1521, 16);


insert into Zamestnanec_pekarne values(190, 'Fiona Pace',  '185-4212 Tempor St.',  'non.enim@google.couk');
insert into Zamestnanec_pekarne values(3646, 'Raja Berry',  '619-6635 A St.',  'tristique.ac@hotmail.edu');
insert into Zamestnanec_pekarne values(4263, 'Illana Morrow',  'Ap #675-1566 Tempor Av.',  'aliquet.libero@icloud.edu');


insert into Pecie_pecivo values(1941, 190);
insert into Pecie_pecivo values(579, 190);
insert into Pecie_pecivo values(3767, 4263);
insert into Pecie_pecivo values(2724, 3646);
insert into Pecie_pecivo values(147, 4263);
insert into Pecie_pecivo values(3287, 190);
insert into Pecie_pecivo values(1521, 3646);
insert into Pecie_pecivo values(1150, 4263);
insert into Pecie_pecivo values(3612, 4263);


insert into Objednavku_vybavuje values(4028, 3646);
insert into Objednavku_vybavuje values(1789, 190);
insert into Objednavku_vybavuje values(2190, 3646);
insert into Objednavku_vybavuje values(3348, 4263);
insert into Objednavku_vybavuje values(4486, 4263);
insert into Objednavku_vybavuje values(4430, 190);
insert into Objednavku_vybavuje values(3002, 4263);


insert into Paserak_pasuje values(4350, 3498);
insert into Paserak_pasuje values(4350, 2252);
insert into Paserak_pasuje values(4350, 2952);
insert into Paserak_pasuje values(4350, 244);



--                                  SELECTY Z ODOVZDANIA 3
-------------------------------------------------------------------------------------------------------------


-- Zobrazi vsetkych vaznov spolu s ich objednavkami, ktorych sucastou bol zapeceny predmet
-- funkcia: zamestnanec si moze prezriet do ktorych objednavok treba zapiect predmet
--SELECT meno, o.ID_objednavky ,O.zapeceny_predmet from Vazen  V natural join Objednavka O;


-- Zobrazi mena paserakov, a objednavok ktore pasuju, spolu s IDckami vaznov pre ktorych su objednavky
-- funkcia: da sa zistit, ktory paserak ma ake objednavky doniest akemu vaznovy
--SELECT Paserak.meno, Objednavka.ID_objednavky, Objednavka.ID_vazna from Paserak natural join Objednavka;


-- zobrazi vsetkych dozorcov, spolu s ich zmenami
-- funkcia: Paserak si moze zobrazit ktory dozorcovia kedy pracuju
--SELECT D.meno Meno_Dozorcu, Z.cas_nastupu, Z.cas_ukoncenia from Zmena Z natural join Dozorca D natural join DOZORCA_PRACUJE;


-- zobrazi vaznov, ID ich objednavok a Nazov vaznice kde byvaju
-- funkcia: zobrazenie Vaznov, ktory si nieco objednali, aku objednavku vytvorili a kde byvaju
--SELECT ID_vazna, Vazen.meno, Objednavka.ID_objednavky, Vaznica.nazov from Vazen
--    natural join Objednavka natural join Cela natural join Vaznica;


-- Zobrazi nazov vaznice a pocet ciel ktore sa v nej nachadzaju
-- funkcia: da sa priblizne zistit velkost vaznice
--SELECT Vaznica.nazov, count(ID_cely) POCET_CIEL from VAZNICA natural join Cela group by Vaznica.nazov;


-- Zobrazi zamestnancov a pocet objednavok ktore vybavuju
-- funkcia: Da sa zistit, ktory zamestnanci aktualne pracuju, a kolko objednavok potrebuju vybavit
--SELECT ID_zamestnanca, meno, count(ID_zamestnanca) from Zamestnanec_pekarne natural join Objednavku_vybavuje
--    group by ID_zamestnanca, meno;


-- Vyberie vsetkych dozorcov, ktory maju zmenu vo vaznici s ID 4350 (FIT)
-- funkcia: mozeme zistit, ktory dozorcovia maju aspon nejaku zmenu v konkretnej vaznici
--SELECT Dozorca.ID_dozorcu, Dozorca.meno from Dozorca
--where ID_dozorcu IN (SELECT ID_dozorcu from Zmena natural join Dozorca_pracuje where Zmena.ID_vaznice = 4350);


-- Zobrazi vsetky informacie o surovinach AK
-- ak existuje aspon jedna objednavka ktorej sucastou je zapeceny predmet
-- funkcia: ak existuje aspon jedna objednavka ktora obsahuje zapeceny predmet
-- je dobre moct skontrolovat zoznam surovin (ci sa zapekane predmety [nozik] nachadzaju v sklade)
--SELECT * from Surovina
--WHERE EXISTS(Select * from Objednavka where zapeceny_predmet IS not NULL );

---------------------------------------------------------------------------------------------------------------------

-- Pridelenie prav veducemu
grant all on Vazen to XRAJKO00;
grant all on Cela to XRAJKO00;
grant all on Vaznica to XRAJKO00;
grant all on Zmena to XRAJKO00;
grant all on Dozorca to XRAJKO00;
grant all on Paserak to XRAJKO00;
grant all on Objednavka to XRAJKO00;
grant all on Pecivo to XRAJKO00;
grant all on Zamestnanec_pekarne to XRAJKO00;
grant all on Surovina to XRAJKO00;
grant all on Obsahuje to XRAJKO00;
grant all on Dozorca_pracuje to XRAJKO00;
grant all on Paserak_pasuje to XRAJKO00;
grant all on Objednavku_vybavuje to XRAJKO00;
grant all on Pecie_pecivo to XRAJKO00;
grant all on Pecivo_obsahuje to XRAJKO00;


-- UKAZKA funkcnosti 1. triggeru, Malo by zobrazit informacie o vaznovi Theodore Sutton
select * from Vazen where ID_vazna = 1;


-----------------------------------------------------------------------------------------------
-- EXPLAIN PLAN + vytvorenie indexu na zrychlenie(bolo by potreba vacsi dataset)/znizenie processor cost
-- po testovani sa na kazdej operacii usetri 1-3 % cpu vykonu

-- EXPLAIN PLAN, vyber vaznov s koncoukou emailu .edu, a pocet ich objednaviek
EXPLAIN PLAN FOR SELECT ID_vazna, meno,e_mail, count(meno) POCET_OBJEDNAVOK from Vazen natural join OBJEDNAVKA
WHERE Vazen.e_mail like '%.edu'
group by ID_vazna, meno, e_mail;
-- Zobrazenie planu
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Znizenie processor cost pre vyhladanie s pomocou indexu
-- Vytvorenie indexu pre emaily vaznov
CREATE INDEX "vazen-objednavka" ON Objednavka(ID_vazna, ID_objednavky);

EXPLAIN PLAN FOR SELECT ID_vazna, meno, e_mail, count(meno) POCET_OBJEDNAVOK from Vazen natural join OBJEDNAVKA
WHERE Vazen.e_mail like '%.edu'
group by ID_vazna, meno, e_mail;
-- Zobrazenie planu po usetreni %CPU
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


drop index "vazen-objednavka";


---------------------------------------------------------------------------------------------
-- MATERIALISED VIEW
-- zobrazi vaznov, ktori maju vytvorene objednavky, spolu s poctom objednavok
CREATE MATERIALIZED VIEW "Vazni-pocet-objednavok" AS
SELECT ID_vazna, meno, e_mail,count(Objednavka.ID_paseraka) Pocet_Objednavok
FROM Vazen
NATURAL JOIN OBJEDNAVKA
GROUP BY Vazen.meno, ID_vazna, e_mail;

-- Ukazka fungovania materialised view
SELECT * FROM "Vazni-pocet-objednavok" where Pocet_Objednavok > 2;

GRANT ALL ON "Vazni-pocet-objednavok" TO XRAJKO00;