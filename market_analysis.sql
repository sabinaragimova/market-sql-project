-- =====================================================================
--  "HANDEXMARKET" DAXİLİ AUDİT İSTİNTAQI
-- =====================================================================
--  HEKAYƏ:
--
--  "HandexMarket" 3 anbarı olan onlayn ticarət şirkətidir. Keçən həftə
--  illik maliyyə yoxlaması bitdi və auditor hesabatda bir cümlə yazdı:
--
--      "Şirkətin uçot sistemindəki mal ehtiyatı ilə fiziki inventarizasiya
--       arasında izah edilməmiş fərq var. Fərq təsadüfi deyil."
--
--  İdarə heyəti şübhələnir, amma heç kimin əlində sübut yoxdur. Şirkətdə
--  kameralar var, lakin yazılar 14 gün saxlanılır - hadisələr isə aylar
--  əvvəl başlayıb. Yeganə uzunmüddətli yaddaş BAZADIR.
--
--  Sən daxili audit şöbəsinin data analitikisən. Baş direktor səni
--  otağına çağırıb deyir:
--
--      "Mən sənə heç bir ad vermirəm, heç kimi göstərmirəm. Çünki səhv
--       adamı ittiham etsək məhkəməyə düşərik. Sən mənə RƏQƏMLƏ gəl.
--       Kim, necə, nə vaxt və neçə manat - hamısı cədvəllər ilə sübut olunsun."
--
--  Bu tapşırıq 17 sualdan ibarətdir və hər sual əvvəlkinin cavabı üzərində
--  qurulub. Sual-sual dairə daralır. 17-ci sualdan sonra YEKUN HESABAT
--  bölməsi var - orada 4 suala cavab yazmalısan.
--
--  ⚠ SUALLARIN ARDICILLIĞINI POZMA. Hər bölmənin sonunda əldə etdiyin
--    ad/nömrə növbəti bölmənin girişidir.
--  ⚠ Sualların çoxunda hansı cədvəllərin lazım olduğu yazılıb. Çətinlik
--    sorğunun texnikasında yox, DÜŞÜNCƏDƏDİR: rəqəmə baxıb nəticə çıxarmaq.
-- =====================================================================


-- =====================================================================
--  CƏDVƏL STRUKTURU (11 cədvəl)
-- =====================================================================
--  Bazanı bir şəkildə göstərmək mümkün deyil, ona görə 3 bloka bölünüb.
--  Bloklar bir-birinə "KÖRPÜ SÜTUNLAR" bölməsindəki sütunlarla bağlanır.
--
--
--  ---------------------------------------------------------------------
--  BLOK A - İNSANLAR VƏ İŞ QRAFİKİ
--  ---------------------------------------------------------------------
--
--     +----------------------+
--     |      WAREHOUSE       |
--     +----------------------+
--     | PK warehouse_id      |
--     |    warehouse_name    |
--     |    city              |
--     |    opening_date      |
--     +----------------------+
--                |1
--                |
--                |N
--     +----------------------+
--     |       EMPLOYEE       |
--     +----------------------+
--     | PK employee_id       |
--     |    first_name        |
--     |    last_name         |
--     |    role_name         |  MANAGER / PICKER / COURIER / SUPPORT
--     | FK warehouse_id      |
--     |    hire_date         |
--     |    status            |
--     +----------------------+
--                |1
--                |
--                |N
--     +----------------------+
--     |      WORK_SHIFT      |
--     +----------------------+
--     | PK shift_id          |
--     | FK employee_id       |
--     |    shift_date        |
--     |    shift_type        |  DAY / NIGHT
--     +----------------------+
--     ⚠ Bu cədvəldə YALNIZ role_name = 'PICKER' olan işçilərin növbələri var.
--       Kuryerlərin və dəstək işçilərinin növbə qeydi saxlanılmır.
--
--
--  ---------------------------------------------------------------------
--  BLOK B - SATIŞ ZƏNCİRİ
--  ---------------------------------------------------------------------
--
--     +----------------------+                +----------------------+
--     |       CUSTOMER       |                |       PRODUCT        |
--     +----------------------+                +----------------------+
--     | PK customer_id       |                | PK product_id        |
--     |    first_name        |                |    product_name      |
--     |    last_name         |                |    category_name     |
--     |    city              |                |    unit_price        |
--     |    register_date     |                |    weight_kg         |
--     +----------------------+                +----------------------+
--                |1                                      |1
--                |                                       |
--                |N                                      |
--     +----------------------+                           |
--     |        ORDERS        |                           |
--     +----------------------+                           |
--     | PK order_id          |                           |
--     | FK customer_id       |                           |
--     | FK warehouse_id      | ---> BLOK A               |
--     |    order_date        |                           |
--     |    order_status      |                           |
--     |    total_amount      |                           |
--     +----------------------+                           |
--          |1       |1       |1                          |
--          |        |        |                           |
--          |N       |1       |N                          |N
--          v        v        v                           v
--   +-------------------+  +-------------------+  ... ORDER_ITEM.product_id
--   |    ORDER_ITEM     |  |     DELIVERY      |
--   +-------------------+  +-------------------+
--   | PK order_item_id  |  | PK delivery_id    |
--   | FK order_id       |  | FK order_id       |
--   | FK product_id     |  | FK courier_id     | ---> BLOK A (EMPLOYEE)
--   |    quantity       |  |    dispatch_date  |
--   |    unit_price     |  |    delivery_date  |
--   +-------------------+  |    delivery_status|
--                          +-------------------+
--
--                          +----------------------------+
--                          |      RETURN_REQUEST        |
--                          +----------------------------+
--                          | PK return_id               |
--                          | FK order_id                |
--                          |    request_date            |
--                          |    reason_code             |
--                          |    return_status           |
--                          | FK approved_by             | ---> BLOK A
--                          |    approve_date            |
--                          |    refund_amount           |
--                          +----------------------------+
--
--     Sifariş zənciri:  customer -> orders -> order_item -> product
--     Çatdırılma:       orders -> delivery -> employee (kuryer)
--     Qaytarma:         orders -> return_request -> employee (təsdiqləyən)
--
--
--  ---------------------------------------------------------------------
--  BLOK C - ANBAR UÇOTU
--  ---------------------------------------------------------------------
--
--     +--------------------------+          +----------------------+
--     |   INVENTORY_MOVEMENT     |          |     STOCK_COUNT      |
--     +--------------------------+          +----------------------+
--     | PK movement_id           |          | PK count_id          |
--     | FK warehouse_id          |          | FK warehouse_id      |
--     | FK product_id            |          | FK product_id        |
--     |    movement_date         |          |    count_date        |
--     |    movement_type         |          |    system_qty        |
--     |    quantity              |          |    counted_qty       |
--     | FK employee_id           |          +----------------------+
--     | FK reference_order_id    |
--     +--------------------------+          system_qty  = sistemə görə
--                                           counted_qty = fiziki sayım
--
--     movement_type dəyərləri və mənası:
--       'IN'         anbara mal qəbulu            quantity MÜSBƏT
--       'OUT'        sifariş üçün yığılıb çıxıb   quantity MƏNFİ
--       'RETURN_IN'  geri qaytarılan mal gəlib    quantity MÜSBƏT
--       'ADJUSTMENT' əl ilə düzəliş (silmə)       quantity MƏNFİ
--
--     reference_order_id:
--       'OUT' və 'RETURN_IN' üçün DOLU (hansı sifarişə aiddir)
--       'IN'  və 'ADJUSTMENT' üçün NULL
--
--
--  ---------------------------------------------------------------------
--  KÖRPÜ SÜTUNLAR (bloklar arası keçidlər)
--  ---------------------------------------------------------------------
--   orders.warehouse_id            -> warehouse            (B -> A)
--   delivery.courier_id            -> employee.employee_id (B -> A)
--   return_request.approved_by     -> employee.employee_id (B -> A)
--   inventory_movement.employee_id -> employee.employee_id (C -> A)
--   inventory_movement.reference_order_id -> orders.order_id (C -> B)
--   work_shift.shift_date          <-> inventory_movement.movement_date
--                                     (eyni işçi + eyni gün ilə birləşir)
--
--
--  ---------------------------------------------------------------------
--  ƏLAQƏLƏR (kardinallıq)
--  ---------------------------------------------------------------------
--   warehouse  1 : N  employee, orders, inventory_movement, stock_count
--   employee   1 : N  work_shift, inventory_movement
--   employee   1 : N  delivery         (courier_id ilə)
--   employee   1 : N  return_request   (approved_by ilə)
--   customer   1 : N  orders
--   orders     1 : N  order_item
--   orders     1 : 1  delivery         (ləğv edilmiş sifarişdə çatdırılma YOXDUR)
--   orders     1 : N  return_request
--   product    1 : N  order_item, inventory_movement, stock_count
--
--
--  ---------------------------------------------------------------------
--  STATUS VƏ KOD DƏYƏRLƏRİ
--  ---------------------------------------------------------------------
--   employee.role_name        'MANAGER' | 'PICKER' | 'COURIER' | 'SUPPORT'
--   employee.status           'ACTIVE'
--   orders.order_status       'DELIVERED' | 'CANCELLED'
--   delivery.delivery_status  'DELIVERED'
--   return_request.reason_code
--        'NOT_RECEIVED'   müştəri "mal əlimə çatmadı" deyir
--        'DAMAGED'        mal zədəli gəlib
--        'WRONG_ITEM'     səhv mal göndərilib
--        'CHANGED_MIND'   müştəri fikrini dəyişib
--   return_request.return_status  'APPROVED' | 'REJECTED'
--   work_shift.shift_type     'DAY' | 'NIGHT'
--
--
--  ---------------------------------------------------------------------
--  NULL OLA BİLƏN SÜTUNLAR
--  ---------------------------------------------------------------------
--   return_request.approved_by     REJECTED olanda da doludur (rədd edən şəxs)
--   return_request.approve_date    yalnız APPROVED olanda doludur
--   inventory_movement.reference_order_id   IN və ADJUSTMENT üçün NULL
--
--
--  ⚠ XƏBƏRDARLIQ
--  ---------------------------------------------------------------------
--   1) Bir sifarişin 3 sətri (order_item) və 1 çatdırılması varsa,
--      bu ikisini eyni anda join etsəniz çatdırılma 3 dəfə sayılacaq.
--      Sifariş saymaq üçün count(distinct order_id) istifadə edin.
--   2) Bir sifarişə birdən çox return_request düşə bilər - delivery ilə
--      join edərkən bu, çatdırılma sayını şişirdir.
--   3) quantity sütunu OUT və ADJUSTMENT-də MƏNFİDİR. Zərəri müsbət
--      rəqəm kimi göstərmək üçün sum(-quantity * unit_price) yazın.
--   4) stock_count-da fərq iki cür hesablana bilər:
--          counted_qty - system_qty  -> itki MƏNFİ çıxır
--          system_qty  - counted_qty -> itki MÜSBƏT çıxır
--      Tapşırıqda hansı istənilibsə onu istifadə edin, qarışdırmayın.
--
-- =====================================================================
--  ÜMUMİ QAYDALAR
-- =====================================================================
-- * Ay sütunu istənilən suallarda to_char(<tarix>, 'YYYY-MM') formatında və
--   month_text adı ilə qaytarılmalıdır.
-- * Tarixlər sysdate-ə nisbətdə yazılmalıdır (add_months / trunc(sysdate) - N).
--   HEÇ VAXT əl ilə tarix yazma.
-- * "İtki miqdarı" = system_qty - counted_qty (müsbət olarsa mal əskikdir).
-- * "İtki dəyəri" = itki miqdarı * product.unit_price.
-- * ADJUSTMENT və OUT hərəkətlərində quantity MƏNFİ saxlanılır; pul dəyərini
--   hesablayarkən işarəyə diqqət et.
-- * Pul və faiz sütunları 2 onluq işarə ilə yuvarlaqlaşdırılmalıdır.
-- * Nəticə sütunlarının adları və sırası tapşırıqda göstərildiyi kimi olmalıdır.
-- =====================================================================



--  BÖLMƏ I - "HARADA?"  (suallar 1-4)
--  Direktor: "Əvvəlcə mənə de görüm problem ümumiyyətlə hansı anbardadır."

-- 1. Əvvəlcə normal mənzərəni gör: son 12 ayda hər anbar üzrə ləğv
--    edilməmiş sifariş sayı və ümumi dövriyyə.
-- Cədvəllər: warehouse, orders
-- Filtr: order_status <> 'CANCELLED' və order_date son 12 ay
-- Nəticə: warehouse_id, warehouse_name, order_count, total_revenue
-- >>> Bu sual sadədir, amma nəticəni yadda saxla: hansı anbar ən böyükdür?
--     Sonrakı suallarda "çox itki" ilə "böyük anbar"ı qarışdırmamaq üçün lazımdır.

select
w.warehouse_id,
w.warehouse_name,
count(o.order_id) order_count,
round(sum(o.total_amount),2) total_revenue
from warehouse w
join orders o on w.warehouse_id = o.warehouse_id
where o.order_status <> 'cancelled'
and o.order_date >= add_months(trunc(sysdate), -12)
group by w.warehouse_id , w.warehouse_name
order by total_revenue desc;

-- 2. İndi inventarizasiya nəticələrinə bax. Hər anbar üzrə neçə sayım
--    qeydi var, ümumi miqdar fərqi və həmin fərqin pul dəyəri nə qədərdir?
-- Cədvəllər: stock_count, warehouse, product
-- Fərq = counted_qty - system_qty (mənfi rəqəm = mal əskikdir)
-- Sıralama: pul fərqi artan (ən böyük itki yuxarıda).
-- Nəticə: warehouse_id, warehouse_name, count_records, total_diff_qty, total_diff_value
-- >>> Bu sualın cavabındakı ANBAR bundan sonrakı bütün suallarda istifadə olunacaq.
--     Onun nömrəsini bir kənara yaz.

select 
    w.warehouse_id,
    w.warehouse_name,
    count(sc.count_id) count_records,
    sum(sc.counted_qty - sc.system_qty) total_diff_qty,
    round(sum((sc.counted_qty - sc.system_qty) * p.unit_price), 2) as total_diff_value
from warehouse w
join stock_count sc on w.warehouse_id = sc.warehouse_id
join product p on sc.product_id = p.product_id
group by w.warehouse_id, w.warehouse_name
order by total_diff_value asc;

-- 3. Problemli anbarda itki nə vaxt başlayıb? Aylar üzrə itki miqdarını
--    və itki dəyərini göstər.
-- Cədvəllər: stock_count, product
-- Ay ölçüsü: count_date · Filtr: yalnız 2-ci sualda tapdığın anbar
-- Sıralama: ay artan.
-- Nəticə: month_text, diff_qty, diff_value
-- ƏLAVƏ (istəyə bağlı, bal artırır): sona bir sütun da əlavə et
--    running_loss = ayların kumulyativ (yığılan) itki dəyəri.
--    İpucu: sum(...) over (order by month_text)

select 
    to_char(sc.count_date, 'yyyy-mm') as month_text,
    sum(sc.counted_qty - sc.system_qty) as diff_qty,
    round(sum((sc.counted_qty - sc.system_qty) * p.unit_price), 2) as diff_value,
    round(sum(sum((sc.counted_qty - sc.system_qty) * p.unit_price)) over (order by to_char(sc.count_date, 'yyyy-mm')), 2) as running_loss
from stock_count sc
join product p on sc.product_id = p.product_id
where sc.warehouse_id = 2
group by to_char(sc.count_date, 'yyyy-mm')
order by month_text asc;


-- 4. Problemli anbarda hansı məhsullar itir? Məhsul üzrə əskik miqdarı və
--    dəyərini göstər. Məhsulun qiymətini və ÇƏKİSİNİ də sütunlara sal.
-- Cədvəllər: stock_count, product
-- Filtr: yalnız əskik çıxanlar (missing_qty > 0) - bunu having ilə filterlə.
-- Sıralama: itki dəyəri azalan.
-- Nəticə: product_id, product_name, unit_price, weight_kg, missing_qty, missing_value
-- >>> Sıranın yuxarısındakı 5 məhsulun ortaq cəhəti nədir? Bir cümlə ilə
--     şərh bölməsinə yaz. (Qiymətə və çəkiyə birlikdə bax.)

select 
    p.product_id,
    p.product_name,
    p.unit_price,
    p.weight_kg,
    sum(sc.system_qty - sc.counted_qty) as missing_qty,
    round(sum((sc.system_qty - sc.counted_qty) * p.unit_price), 2) as missing_value
from stock_count sc
join product p on sc.product_id = p.product_id
where sc.warehouse_id = 2
group by p.product_id, p.product_name, p.unit_price, p.weight_kg
having sum(sc.system_qty - sc.counted_qty) > 0
order by missing_value desc;


--  BÖLMƏ II - "ANBARIN İÇİNDƏ KİM?"  (suallar 5-8)
--  Direktor: "Mal öz-özünə yox olmur. Sistemə kim toxunub?"

-- 5. Sistemdə malı "silmək" üçün ADJUSTMENT hərəkəti istifadə olunur.
--    Bütün anbarlar üzrə hansı işçi neçə ADJUSTMENT edib, ümumi miqdar
--    və ümumi pul dəyəri nə qədərdir?
-- Cədvəllər: inventory_movement, employee, product, warehouse
-- Filtr: movement_type = 'ADJUSTMENT'
-- Sıralama: pul dəyəri artan (ən böyük mənfi yuxarıda).
-- Nəticə: employee_id, full_name, warehouse_name, adjustment_count,
--         total_adjusted_qty, total_adjusted_value
-- >>> Burada bir işçi qalan hamıdan kəskin fərqlənir. Onun employee_id-si
--     bundan sonra "ŞÜBHƏLİ №1"dir. Nömrəsini yaz.

select 
    e.employee_id,
    e.first_name || ' ' || e.last_name as full_name,
    w.warehouse_name,
    count(im.movement_id) as adjustment_count,
    sum(im.quantity) as total_adjusted_qty,
    round(sum(im.quantity * p.unit_price), 2) as total_adjusted_value
from inventory_movement im
join employee e on im.employee_id = e.employee_id
join warehouse w on im.warehouse_id = w.warehouse_id
join product p on im.product_id = p.product_id
where im.movement_type = 'ADJUSTMENT'
group by e.employee_id, e.first_name, e.last_name, w.warehouse_name
order by total_adjusted_value asc;

-- 6. Hər ADJUSTMENT hərəkətinin edildiyi gün həmin işçinin növbəsi nə idi?
--    İşçi və növbə tipi üzrə hərəkət sayını göstər.
-- Cədvəllər: inventory_movement, employee, work_shift
-- Birləşdirmə: work_shift ilə HƏM employee_id, HƏM DƏ tarix üzrə birləşdirin
--              (on s.employee_id = m.employee_id and s.shift_date = m.movement_date)
-- Qeyd: həmin gün işçinin ümumiyyətlə növbəsi yoxdursa 'NOVBESIZ' yazılsın
--       (left join + nvl).
-- Nəticə: employee_id, full_name, shift_type, adjustment_count
-- >>> ŞÜBHƏLİ №1-in düzəlişləri əsasən hansı növbədə edilib?

select 
    e.employee_id,
    e.first_name || ' ' || e.last_name as full_name,
    nvl(ws.shift_type, 'NOVBESIZ') as shift_type,
    count(im.movement_id) as adjustment_count
from inventory_movement im
join employee e on im.employee_id = e.employee_id
left join work_shift ws on im.employee_id = ws.employee_id 
                        and im.movement_date = ws.shift_date
where im.movement_type = 'ADJUSTMENT'
group by e.employee_id, e.first_name, e.last_name, nvl(ws.shift_type, 'NOVBESIZ')
order by e.employee_id, adjustment_count desc;

-- 7. İndi 6-cı sualdakı 'NOVBESIZ' sətirlərin arxasında nə olduğuna bax:
--    hansı ADJUSTMENT hərəkətləri işçinin ÜMUMİYYƏTLƏ növbədə OLMADIĞI
--    gün edilib? Yəni adam işdə deyildi, amma sistemə giriş olub.
-- Cədvəllər: inventory_movement, employee, product, work_shift
-- Həll: not exists
-- Sıralama: tarix artan.
-- Nəticə: movement_id, employee_id, full_name, movement_date, product_name, quantity
-- >>> Bu, hesabatın ən güclü sübutudur. Neçə sətirdir və kimə aiddir?

select 
    im.movement_id,
    e.employee_id,
    e.first_name || ' ' || e.last_name as full_name,
    im.movement_date,
    p.product_name,
    im.quantity
from inventory_movement im
join employee e on im.employee_id = e.employee_id
join product p on im.product_id = p.product_id
where im.movement_type = 'ADJUSTMENT'
  and not exists (
      select 1 
      from work_shift ws 
      where ws.employee_id = im.employee_id 
        and ws.shift_date = im.movement_date
  )
order by im.movement_date asc;

-- 8. ŞÜBHƏLİ №1-in bütün ADJUSTMENT hərəkətlərini xronoloji sırala və hər
--    hərəkət üçün ƏVVƏLKİ hərəkətdən neçə gün keçdiyini hesabla.
-- Cədvəllər: inventory_movement, product
-- Filtr: movement_type = 'ADJUSTMENT' və employee_id = ŞÜBHƏLİ №1
-- İpucu: lag(movement_date) over (order by movement_date)
--        Oracle-da iki tarixi çıxsan nəticə gün sayı olur.
-- Nəticə: movement_id, movement_date, product_name, quantity, prev_date, days_since_prev
-- >>> Aralıqlara bax: təsadüfi görünür, yoxsa qrafik üzrə?

select 
    im.movement_id,
    im.movement_date,
    p.product_name,
    im.quantity,
    (
        select max(prev.movement_date)
        from inventory_movement prev
        where prev.employee_id = im.employee_id
          and prev.movement_type = 'ADJUSTMENT'
          and prev.movement_date < im.movement_date
    ) as prev_date,
    round(
        im.movement_date - (
            select max(prev.movement_date)
            from inventory_movement prev
            where prev.employee_id = im.employee_id
              and prev.movement_type = 'ADJUSTMENT'
              and prev.movement_date < im.movement_date
        ), 0
    ) as days_since_prev
from inventory_movement im
join product p on im.product_id = p.product_id
where im.movement_type = 'ADJUSTMENT'
  and im.employee_id = 204
order by im.movement_date asc;

--  BÖLMƏ III - "ANBARDAN KƏNARDA NƏ BAŞ VERİR?"  (suallar 9-12)
--  Direktor: "Anbar itkisi hesabatdakı fərqin hamısını izah etmir.
--             Başqa bir boşluq da var."

-- 9. Geri qaytarma səbəbləri üzrə ümumi mənzərə: hər səbəb kodu üzrə
--    müraciət sayı və ümumi geri ödəniş məbləği.
-- Cədvəllər: return_request
-- Sıralama: müraciət sayı azalan.
-- Nəticə: reason_code, request_count, total_refund
-- >>> Sağlam onlayn mağazada "mal çatmadı" iddiası bütün qaytarmaların
--     5-10%-i olur. Burada nə qədərdir? Öz-özünə hesabla və şərh yaz.
-- ƏLAVƏ (istəyə bağlı): sonuncu sütun kimi pct_of_all əlavə et —
--    hər səbəbin ümumi say içindəki faizi.

select 
    reason_code,
    count(return_id) as request_count,
    round(sum(refund_amount), 2) as total_refund,
    round(count(return_id) * 100.0 / sum(count(return_id)) over (), 2) as pct_of_all
from return_request
group by reason_code
order by request_count desc;

-- 10. Kuryerlər üzrə: neçə sifariş çatdırıb, həmin sifarişlərdən neçəsi
--     üçün 'NOT_RECEIVED' iddiası verilib və bu neçə faizdir?
-- Cədvəllər: delivery, employee, return_request
-- Birləşdirmə: return_request-i left join ilə qoşun (iddiası olmayan
--              çatdırılmalar da sayılmalıdır).
-- DİQQƏT: bir sifarişə birdən çox qaytarma düşə bilər - çatdırılma sayını
--         count(distinct d.order_id) ilə hesablayın, yoxsa faiz şişəcək.
-- Filtr: ən azı 10 çatdırılma etmiş kuryerlər (having).
-- Sıralama: faiz azalan.
-- Nəticə: courier_id, full_name, delivered_count, not_received_count, not_received_pct
-- >>> Burada da bir nəfər qalan hamıdan kəskin fərqlənir.
--     Onun employee_id-si "ŞÜBHƏLİ №2"dir. Nömrəsini yaz.

select 
    e.employee_id as courier_id,
    e.first_name || ' ' || e.last_name as full_name,
    count(distinct d.order_id) as delivered_count,
    count(distinct case when rr.reason_code = 'NOT_RECEIVED' then d.order_id end) as not_received_count,
    round(
        count(distinct case when rr.reason_code = 'NOT_RECEIVED' then d.order_id end) * 100.0 / count(distinct d.order_id), 
        2
    ) as not_received_pct
from delivery d
join employee e on d.courier_id = e.employee_id
left join return_request rr on d.order_id = rr.order_id
group by e.employee_id, e.first_name, e.last_name
having count(distinct d.order_id) >= 10
order by not_received_pct desc;


-- 11. Məntiq yoxlaması: geri qaytarma TƏSDİQLƏNİBSƏ (APPROVED), mal fiziki
--     olaraq anbara qayıtmalıdır - yəni həmin sifariş üçün 'RETURN_IN'
--     hərəkəti olmalıdır (inventory_movement.reference_order_id sütunu).
--     Təsdiqlənib, amma anbara HEÇ NƏ qayıtmayan halları tap və səbəb kodu
--     üzrə qrupla.
-- Cədvəllər: return_request, inventory_movement
-- Həll: not exists
-- Nəticə: reason_code, request_count, total_loss
-- >>> Hansı səbəb kodunda mal demək olar heç vaxt geri gəlmir? Niyə?

select 
    rr.reason_code,
    count(distinct rr.return_id) as request_count,
    round(sum(rr.refund_amount), 2) as total_loss
from return_request rr
where rr.return_status = 'APPROVED'
  and not exists (
      select 1 
      from inventory_movement im 
      where im.reference_order_id = rr.order_id 
        and im.movement_type = 'RETURN_IN'
  )
group by rr.reason_code
order by total_loss desc;

-- 12. Bu təsdiqləri kim verib? Hər işçi üzrə təsdiqlədiyi müraciət sayı,
--     müraciətdən təsdiqə qədər ORTA gün sayı və bunların içində neçəsinin
--     'NOT_RECEIVED' olduğu.
-- Cədvəllər: return_request, employee
-- Filtr: return_status = 'APPROVED'
-- Orta gün: avg(approve_date - request_date)
-- Sıralama: orta gün sayı artan.
-- Nəticə: employee_id, full_name, approved_count, avg_approve_days, not_received_count
-- >>> Normal təsdiq müddəti neçə gündür? Kim fərqlənir?

select 
    e.employee_id,
    e.first_name || ' ' || e.last_name as full_name,
    count(rr.return_id) as approved_count,
    round(avg(rr.approve_date - rr.request_date), 2) as avg_approve_days,
    count(case when rr.reason_code = 'NOT_RECEIVED' then 1 end) as not_received_count
from return_request rr
join employee e on rr.approved_by = e.employee_id
where rr.return_status = 'APPROVED'
group by e.employee_id, e.first_name, e.last_name
order by avg_approve_days asc;

--  BÖLMƏ IV - "SXEM"  (suallar 13-16)
--  Direktor: "Kuryer tək başına bunu edə bilməz. Kimsə sifariş verməlidir."

-- 13. Təsdiqlənmiş 'NOT_RECEIVED' iddialarını müştəri üzrə qrupla:
--     hansı müştəri neçə dəfə iddia edib və şirkətə nə qədər başa gəlib?
-- Cədvəllər: return_request, orders, customer
-- Filtr: reason_code = 'NOT_RECEIVED' və return_status = 'APPROVED'
--        və ən azı 2 iddia (having)
-- Sıralama: məbləğ azalan.
-- Nəticə: customer_id, full_name, city, register_date, claim_count, total_refund
-- >>> Neçə nəfər çıxdı? Soyadlarına, şəhərlərinə və customer_id-lərinə diqqətlə bax.

select 
    c.customer_id,
    c.first_name || ' ' || c.last_name as full_name,
    c.city,
    c.register_date,
    count(rr.return_id) as claim_count,
    round(sum(rr.refund_amount), 2) as total_refund
from return_request rr
join orders o on rr.order_id = o.order_id
join customer c on o.customer_id = c.customer_id
where rr.reason_code = 'NOT_RECEIVED'
  and rr.return_status = 'APPROVED'
group by c.customer_id, c.first_name, c.last_name, c.city, c.register_date
having count(rr.return_id) >= 2
order by total_refund desc;

-- 14. 13-cü sualdakı müştərilərin sifarişlərini kim çatdırıb?
--     Müştəri və kuryer üzrə sifariş sayını göstər.
-- Cədvəllər: orders, delivery, employee, customer
-- Filtr: yalnız 13-cü sualda tapdığın müştərilər (customer_id in (...))
-- Sıralama: customer_id artan.
-- Nəticə: customer_id, full_name, courier_id, courier_name, order_count
-- >>> Həmin anbarda 3 kuryer işləyir. Sifarişlər onların arasında necə bölünüb?
--     Bu, təsadüf ola bilərmi? Bir cümlə ilə şərh yaz.

select 
    c.customer_id,
    c.first_name || ' ' || c.last_name as full_name,
    e.employee_id as courier_id,
    e.first_name || ' ' || e.last_name as courier_name,
    count(o.order_id) as order_count
from orders o
join delivery d on o.order_id = d.order_id
join employee e on d.courier_id = e.employee_id
join customer c on o.customer_id = c.customer_id
where o.customer_id in (1101, 1102, 1103, 1104, 1105)
group by c.customer_id, c.first_name, c.last_name, e.employee_id, e.first_name, e.last_name
order by c.customer_id asc;

-- 15. Ziddiyyəti rəqəmlə göstər: delivery_status = 'DELIVERED' (kuryer
--     "təhvil verdim" deyib), amma müştəri "mal əlimə çatmadı" deyib və
--     bu iddia TƏSDİQLƏNİB. Kuryerlər üzrə say və məbləğ.
-- Cədvəllər: return_request, delivery, employee
-- Sıralama: məbləğ azalan.
-- Nəticə: courier_id, full_name, contradiction_count, total_loss

select 
    e.employee_id as courier_id,
    e.first_name || ' ' || e.last_name as full_name,
    count(distinct rr.return_id) as contradiction_count,
    round(sum(rr.refund_amount), 2) as total_loss
from return_request rr
join delivery d on rr.order_id = d.order_id
join employee e on d.courier_id = e.employee_id
where d.delivery_status = 'DELIVERED'
  and rr.reason_code = 'NOT_RECEIVED'
  and rr.return_status = 'APPROVED'
group by e.employee_id, e.first_name, e.last_name
order by total_loss desc;


-- 16. Şübhəli müştərilərin qeydiyyat tarixlərinə bax: onları qeydiyyat
--     tarixinə görə sırala və hər birinin ƏVVƏLKİNDƏN neçə gün sonra
--     qeydiyyatdan keçdiyini hesabla.
-- Cədvəllər: customer
-- Əhatə: 13-cü sualda tapdığın müştərilər
-- İpucu: lag(register_date) over (order by register_date)
-- Nəticə: customer_id, full_name, register_date, days_after_previous
-- >>> Nəticə təsadüfə oxşayırmı?

select 
    customer_id,
    first_name || ' ' || last_name as full_name,
    register_date,
    round(register_date - lag(register_date) over (order by register_date), 0) as days_after_previous
from customer
where customer_id in (1101, 1102, 1103, 1104, 1105)
order by register_date asc;


--  BÖLMƏ V - ZƏRƏR

-- 17. Şirkətin ümumi zərərini iki kanal üzrə hesabla və bir nəticə
--     dəstində birləşdir (union all):
--       kanal 1 - 'ANBAR_DUZELISI'  : ŞÜBHƏLİ №1-in ADJUSTMENT hərəkətləri
--                                     (inventory_movement + product)
--       kanal 2 - 'SAXTA_QAYTARMA'  : ŞÜBHƏLİ №2-nin çatdırdığı sifarişlər
--                                     üzrə təsdiqlənmiş NOT_RECEIVED məbləği
--                                     (return_request + delivery)
-- Nəticə: channel_name, loss_amount
-- >>> İki rəqəmi topla - direktora deyəcəyin məbləğ budur.

select 
    'ANBAR_DUZELISI' as channel_name,
    round(sum(abs(im.quantity) * p.unit_price), 2) as loss_amount
from inventory_movement im
join product p on im.product_id = p.product_id
where im.employee_id = 204
  and im.movement_type = 'ADJUSTMENT'

union all

select 
    'SAXTA_QAYTARMA' as channel_name,
    round(sum(rr.refund_amount), 2) as loss_amount
from return_request rr
join delivery d on rr.order_id = d.order_id
where d.courier_id = 206
  and rr.reason_code = 'NOT_RECEIVED'
  and rr.return_status = 'APPROVED';


--yekun zerer = 20,385 + 27,920 = 48,305 azn


--  YEKUN HESABAT (bunu SQL şərhi kimi faylın sonuna yaz)

--  Direktora 4 sualın cavabını yaz. Hər cavabın yanında HANSI SUALIN
--  nəticəsinə əsaslandığını göstər (məsələn: "sual 5 və 7-yə əsasən").
--
--  A) Anbar itkisinə görə kim məsuliyyət daşıyır? Sübut nədir?

-- Anbar itkisine gore Rovsen Nebiyev (204) mesuliyyet dasiyir. Subut odur ki, Baki-2 anbarindaki 
--'ADJUSTMENT' senedlerini senedsiz-fakturasiz tekbasina silib (Sual 5 ve 7-ye esasen).

--  B) Geri qaytarma sxemində kim iştirak edir? Neçə nəfərlik qrupdur?

--Sxemde 8 nefer istirak edir: kuryer Ceyhun Semedov (206), mutexessis Aygun Sukurova (208), 
--anbardar Rovsen Nebiyev (204) ve 5 saxta musteri (1101-1105) (Sual 10, 12, 13 ve 16-ya esasen).

--  C) Sxem TEXNİKİ olaraq necə işləyir? (3-4 cümlə, addım-addım)

-- Ardicil acilan 5 saxta profille baha sifarisler verilir. Kuryer Ceyhun mali 'DELIVERED' edir, 
--amma musteri "catmadi" deye muraciet acir. Aygun Sukurova da yoxlamadan hemin gun qaytarmani tesdiqleyir 
--ve pulu hemin saxta hesablara qaytarir (Sual 11, 14, 15 ve 16-ya esasen).

--  D) Şirkətin ümumi zərəri neçə manatdır?
--yekun zerer = 20,385 + 27,920 = 48,305 azn


