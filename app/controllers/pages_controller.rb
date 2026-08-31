class PagesController < ApplicationController
  def home
  end

  def services
    @services = [
      { name: "Tune-up",                price: 45 },
      { name: "Wheel true",             price: 20 },
      { name: "Brake bleed",            price: 30 },
      { name: "Chain replacement",      price: 35 },
      { name: "Flat tire repair",       price: 15 },
      { name: "Tube replacement",       price: 12 },
      { name: "Gear adjustment",        price: 25 },
      { name: "Bottom bracket service", price: 40 },
      { name: "Headset service",        price: 35 },
      { name: "Wheel build",            price: 80 },
      { name: "Suspension fork service", price: 70 },
      { name: "Full service overhaul",  price: 120 }
    ]
  end

  def visiting
  end

  def about
  end
end
