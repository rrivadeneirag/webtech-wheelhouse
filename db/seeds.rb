# db/seeds.rb — Wheelhouse workshop data (Lab 5).
#
# Idempotent: the tables are cleared first, then rebuilt, so running this file a
# second time leaves the same number of rows as the first run.
# Every write uses create!, so a failed insert raises instead of being skipped.
# Dates are written relative to the day the seed runs (Time.current / Date.current)
# so a repair that is overdue today is still overdue whenever the file is run.

# --- Reset (children before parents) -------------------------------------------
RepairService.delete_all
Repair.delete_all
Bike.delete_all
Service.delete_all
Staff.delete_all
Customer.delete_all

# --- Services: the wall list (the same twelve the public page shows) ------------
price_list = {
  "Tune-up"                 => 45,
  "Wheel true"              => 20,
  "Brake bleed"             => 30,
  "Chain replacement"       => 35,
  "Flat tire repair"        => 15,
  "Tube replacement"        => 12,
  "Gear adjustment"         => 25,
  "Bottom bracket service"  => 40,
  "Headset service"         => 35,
  "Wheel build"             => 80,
  "Suspension fork service" => 70,
  "Full service overhaul"   => 120,
}

services = {}
price_list.each do |name, price|
  services[name] = Service.create!(name: name, price: price, active: true)
end

# --- Staff: three mechanics and the person at the counter -----------------------
diego   = Staff.create!(name: "Diego Fuentes",   role: "Mechanic")
camila  = Staff.create!(name: "Camila Rojas",    role: "Mechanic")
ignacio = Staff.create!(name: "Ignacio Soto",    role: "Mechanic")
Staff.create!(name: "Valentina Pérez", role: "Counter")

# --- Customers (11) -------------------------------------------------------------
ana      = Customer.create!(name: "Ana Morales",     phone: "+56 9 8123 4567")
benjamin = Customer.create!(name: "Benjamín Silva",  phone: "+56 9 8234 5678")
carla    = Customer.create!(name: "Carla Núñez",     phone: "+56 9 8345 6789")
diegoh   = Customer.create!(name: "Diego Herrera",   phone: "+56 9 8456 7890")
elena    = Customer.create!(name: "Elena Vargas",    phone: "+56 9 8567 8901")
felipe   = Customer.create!(name: "Felipe Castro",   phone: "+56 9 8678 9012")
gabriela = Customer.create!(name: "Gabriela Torres", phone: "+56 9 8789 0123")
hugo     = Customer.create!(name: "Hugo Ramírez",    phone: "+56 9 8890 1234")
isidora  = Customer.create!(name: "Isidora Fuentes", phone: "+56 9 8901 2345")
joaquin  = Customer.create!(name: "Joaquín Muñoz",   phone: "+56 9 9012 3456")
karina   = Customer.create!(name: "Karina Díaz",     phone: "+56 9 9123 4567")

# --- Bikes (13) -----------------------------------------------------------------
# Ana owns two bikes. marlin_a and marlin_b are the same make, model and colour and
# differ ONLY in their serial number (the "two blue Trek Marlins" case).
marlin_a = Bike.create!(customer_id: ana.id,      make_model: "Trek Marlin 5",          colour: "Blue",   serial_number: "WTU100001")
sirrus   = Bike.create!(customer_id: ana.id,      make_model: "Specialized Sirrus",     colour: "Black",  serial_number: "SPX100002")
marlin_b = Bike.create!(customer_id: benjamin.id, make_model: "Trek Marlin 5",          colour: "Blue",   serial_number: "WTU100003")
escape   = Bike.create!(customer_id: carla.id,    make_model: "Giant Escape 3",         colour: "Grey",   serial_number: "GNT100004")
quick    = Bike.create!(customer_id: diegoh.id,   make_model: "Cannondale Quick 4",     colour: "Red",    serial_number: "CDL100005")
aspect   = Bike.create!(customer_id: elena.id,    make_model: "Scott Aspect 950",       colour: "Green",  serial_number: "SCT100006")
fx       = Bike.create!(customer_id: felipe.id,   make_model: "Trek FX 2",              colour: "White",  serial_number: "TFX100007")
bignine  = Bike.create!(customer_id: gabriela.id, make_model: "Merida Big Nine",        colour: "Orange", serial_number: "MRD100008")
rock     = Bike.create!(customer_id: hugo.id,     make_model: "Specialized Rockhopper", colour: "Black",  serial_number: "SPR100009")
talon    = Bike.create!(customer_id: isidora.id,  make_model: "Giant Talon 3",          colour: "Blue",   serial_number: "GTL100010")
aim      = Bike.create!(customer_id: joaquin.id,  make_model: "Cube Aim",               colour: "Grey",   serial_number: "CBE100011")
domane   = Bike.create!(customer_id: joaquin.id,  make_model: "Trek Domane AL 2",       colour: "Black",  serial_number: "TDM100012")
Bike.create!(customer_id: karina.id, make_model: "Orbea Onix", colour: "Yellow", serial_number: "ORB100013") # Karina: a bike but no repairs

# --- Helper: attach line items to a repair --------------------------------------
# items is a list of [service name, charged price]. charged_price is stored on the
# join row, separate from the current list price, so old invoices keep their prices.
def add_services(repair, services, items)
  items.each do |name, charged|
    RepairService.create!(repair_id: repair.id, service_id: services.fetch(name).id, charged_price: charged)
  end
end

# --- Repairs (16, covering every lifecycle state at least once) -----------------

# R1 — RECEIVED: just arrived, no mechanic assigned yet, never quoted (no services).
Repair.create!(bike_id: marlin_a.id, mechanic_id: nil, status: "Received",
               received_at: 1.day.ago, promised_on: nil, handed_back_at: nil)

# R2 — same bike as R1, an earlier COLLECTED repair -> one bike, two repairs, different dates.
r2 = Repair.create!(bike_id: marlin_a.id, mechanic_id: diego.id, status: "Collected",
                    received_at: 3.months.ago, promised_on: (3.months.ago.to_date + 3),
                    handed_back_at: (3.months.ago + 4.days))
add_services(r2, services, [["Tune-up", 45], ["Brake bleed", 30]])

# R3 — ASSESSED: estimate being built.
r3 = Repair.create!(bike_id: escape.id, mechanic_id: camila.id, status: "Assessed",
                    received_at: 2.days.ago, promised_on: (Date.current + 3), handed_back_at: nil)
add_services(r3, services, [["Tune-up", 45]])

# R4 — AWAITING APPROVAL: quote sent, no answer yet, not handed back.
r4 = Repair.create!(bike_id: quick.id, mechanic_id: camila.id, status: "Awaiting approval",
                    received_at: 1.day.ago, promised_on: (Date.current + 4), handed_back_at: nil)
add_services(r4, services, [["Wheel true", 20], ["Gear adjustment", 25]])

# R5 — APPROVED: the customer heard the price and said yes. (Chain charged below list.)
r5 = Repair.create!(bike_id: aspect.id, mechanic_id: ignacio.id, status: "Approved",
                    received_at: 4.days.ago, promised_on: (Date.current + 2), handed_back_at: nil)
add_services(r5, services, [["Full service overhaul", 120], ["Brake bleed", 30], ["Chain replacement", 30]])

# R6 — DECLINED: the customer refused the estimate; not handed back yet.
r6 = Repair.create!(bike_id: fx.id, mechanic_id: diego.id, status: "Declined",
                    received_at: 5.days.ago, promised_on: nil, handed_back_at: nil)
add_services(r6, services, [["Suspension fork service", 70]])

# R7 — IN PROGRESS and OVERDUE: promised date has passed, not handed back.
r7 = Repair.create!(bike_id: bignine.id, mechanic_id: camila.id, status: "In progress",
                    received_at: 6.days.ago, promised_on: 5.days.ago.to_date, handed_back_at: nil)
add_services(r7, services, [["Wheel build", 80], ["Headset service", 35], ["Bottom bracket service", 40]])

# R8 — IN PROGRESS, on time.
r8 = Repair.create!(bike_id: rock.id, mechanic_id: ignacio.id, status: "In progress",
                    received_at: 2.days.ago, promised_on: (Date.current + 3), handed_back_at: nil)
add_services(r8, services, [["Tune-up", 45], ["Flat tire repair", 15]])

# R9 — READY: finished but not collected (no hand-back date).
r9 = Repair.create!(bike_id: talon.id, mechanic_id: diego.id, status: "Ready",
                    received_at: 3.days.ago, promised_on: (Date.current + 1), handed_back_at: nil)
add_services(r9, services, [["Brake bleed", 30], ["Gear adjustment", 25]])

# R10 — COLLECTED: came in and went out the SAME DAY.
r10 = Repair.create!(bike_id: aim.id, mechanic_id: camila.id, status: "Collected",
                     received_at: Time.current.change(hour: 9), promised_on: Date.current,
                     handed_back_at: Time.current.change(hour: 17))
add_services(r10, services, [["Flat tire repair", 15]])

# R11 — COLLECTED: a normal finished job.
r11 = Repair.create!(bike_id: domane.id, mechanic_id: ignacio.id, status: "Collected",
                     received_at: 10.days.ago, promised_on: 8.days.ago.to_date, handed_back_at: 7.days.ago)
add_services(r11, services, [["Tune-up", 45], ["Chain replacement", 35]])

# R12 — COLLECTED: a service charged BELOW the list price (Wheel true 15, list 20).
r12 = Repair.create!(bike_id: marlin_b.id, mechanic_id: diego.id, status: "Collected",
                     received_at: 20.days.ago, promised_on: 17.days.ago.to_date, handed_back_at: 16.days.ago)
add_services(r12, services, [["Wheel true", 15], ["Brake bleed", 30]])

# R13 — COLLECTED, from BEFORE last January: charged prices differ from today's list.
r13 = Repair.create!(bike_id: sirrus.id, mechanic_id: camila.id, status: "Collected",
                     received_at: 14.months.ago, promised_on: (14.months.ago.to_date + 5),
                     handed_back_at: (14.months.ago + 4.days))
add_services(r13, services, [["Tune-up", 38], ["Brake bleed", 26]])

# R14 — COLLECTED (aspect's earlier repair; another bike with more than one repair).
r14 = Repair.create!(bike_id: aspect.id, mechanic_id: ignacio.id, status: "Collected",
                     received_at: 2.months.ago, promised_on: (2.months.ago.to_date + 3),
                     handed_back_at: (2.months.ago + 4.days))
add_services(r14, services, [["Gear adjustment", 25], ["Tune-up", 45]])

# R15 — COLLECTED.
r15 = Repair.create!(bike_id: bignine.id, mechanic_id: diego.id, status: "Collected",
                     received_at: 5.months.ago, promised_on: (5.months.ago.to_date + 2),
                     handed_back_at: (5.months.ago + 3.days))
add_services(r15, services, [["Headset service", 35]])

# R16 — COLLECTED.
r16 = Repair.create!(bike_id: talon.id, mechanic_id: camila.id, status: "Collected",
                     received_at: 40.days.ago, promised_on: 37.days.ago.to_date, handed_back_at: 36.days.ago)
add_services(r16, services, [["Tube replacement", 12], ["Flat tire repair", 15]])

puts "Seed complete:"
puts "  #{Customer.count} customers, #{Bike.count} bikes, #{Staff.count} staff"
puts "  #{Service.count} services, #{Repair.count} repairs, #{RepairService.count} line items"
