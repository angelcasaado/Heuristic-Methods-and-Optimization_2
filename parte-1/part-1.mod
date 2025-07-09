#Conjuntos
set AVIONES; #Conjunto de los aviones 
set TARIFAS; #Conjunto de las tarifas (1:Estandar, 2:Leisure, 3:Business)

#Parametros
param asientos {AVIONES}; #El numero de asientos que tendra cada avion
param capacidad_equipaje {AVIONES}; #La capacidad que tiene cada avion para el equipaje en kg
param precio_billete {TARIFAS}; #El precio de cada billete dependiendo de la tarifa
param peso_equipaje {TARIFAS}; #El peso del equipaje que permite cada tarifa

#Parametros para el minimo de billetes
param min_billetes_leisure; #El minimo de billetes de la tarifa Leisure
param min_billetes_business; #El minimo de billetes de la tarifa Business

#Variables
var billetes_vendidos {AVIONES, TARIFAS} integer, >= 0; #El numero de billetes vendidos de cada tarifa en cada avion

#Funcion Objetivo
maximize Ingresos: sum {i in AVIONES, j in TARIFAS} precio_billete[j] * billetes_vendidos[i,j];

#Restriccion: No se pueden vender mas billetes que el numero de asientos disponibles en el avion.
s.t. MaxAsientos {i in AVIONES}: sum {j in TARIFAS} billetes_vendidos[i,j] <= asientos[i];  
#Restriccion: No se puede superar en ningun caso la capacidad maxima de cada avion
s.t. MaxCapadidadEquipaje {i in AVIONES}: sum {j in TARIFAS} peso_equipaje[j] * billetes_vendidos[i,j] <= capacidad_equipaje[i];
#Restriccion: Para cada avion, se deben ofertar como minimo 20 billetes Leisure plus
s.t. MinLeisure {i in AVIONES}: billetes_vendidos[i,2] >= min_billetes_leisure;
#Restriccion: Para cada avion, se deben ofertar como minimo 10 billetes Business plus
s.t. MinBusiness {i in AVIONES}: billetes_vendidos[i,3] >= min_billetes_business;
#Restriccion: El numero de billetes Estandar total debe ser al menos un 60 % de todos los billetes que se ofertan
s.t. MinEstandar: sum {i in AVIONES} billetes_vendidos[i,1] >= 0.6 * sum {i in AVIONES, j in TARIFAS} billetes_vendidos[i,j];

end;
