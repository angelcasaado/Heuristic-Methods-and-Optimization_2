#Conjuntos
set AVIONES; #Conjunto de los aviones 
set TARIFAS; #Conjunto de las tarifas (1:Estandar, 2:Leisure, 3:Business)
set PISTAS; #Conjunto de las pistas
set SLOTS; #Conjunto de los slots de tiempo

#Parametros de la parte 1 
param asientos {AVIONES}; #El numero de asientos que tendra cada avion
param capacidad_equipaje {AVIONES}; #La capacidad que tiene cada avion para el equipaje en kg
param precio_billete {TARIFAS}; #El precio de cada billete dependiendo de la tarifa
param peso_equipaje {TARIFAS}; #El peso del equipaje que permite cada tarifa
param min_billetes_leisure; #El minimo de billetes de la tarifa Leisure
param min_billetes_business; #El minimo de billetes de la tarifa Business

#Parametros de la parte 2
param hora_programada_llegada {AVIONES}; #La hora de llegada programada de cada avion
param hora_limite_llegada {AVIONES}; #La hora limite de cada avion
param coste_retraso {AVIONES}; #El coste de retraso de cada avion por cada minuto
param hora_inicio_slot {PISTAS, SLOTS}; #La hora de inicio de cada pista en cada slot de tiempo
param pista_disponible {PISTAS, SLOTS} binary; #La disponibilidad de cada pista en cada slot de tiempo
param num_slots; #Definimos el numero de slots que utilicemos como parametro

#Variables de la parte 1
var billetes_vendidos {AVIONES, TARIFAS} integer, >= 0; #El numero de billetes vendidos de cada tarifa en cada avion

#Variables de la parte 2
var asignacion_slots {AVIONES, PISTAS, SLOTS} binary;  #La asignacion del slot de tiempo en cada pista a cada avion
var retraso {AVIONES} >= 0;  #Los minutos de retraso de cada avion

#Funcion Objetivo
maximize Beneficio:
    sum {i in AVIONES, j in TARIFAS} precio_billete[j] * billetes_vendidos[i,j] - sum {i in AVIONES} retraso[i] * coste_retraso[i];

#Restricciones de la parte 1
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

#Restricciones de la parte 2
#Restriccion: Todos los aviones tienen que tener asignado un slot de tiempo para efectuar el aterrizaje
s.t. AsignacionUnica {i in AVIONES}:
    sum {k in PISTAS, t in SLOTS} asignacion_slots[i,k,t] = 1;
#Restriccion: Un slot de tiempo puede estar asignado como maximo a un avion
s.t. UnAvionPorSlot {k in PISTAS, t in SLOTS}:
    sum {i in AVIONES} asignacion_slots[i, k, t] <= 1;
#Restriccion: El slot que se asigna a un avion debe ser un slot libre 
s.t. RestriccionDisponibilidad {i in AVIONES, k in PISTAS, t in SLOTS}:
    asignacion_slots[i,k,t] <= pista_disponible[k,t];
#Restriccion: El inicio del slot de aterrizaje debe ser igual o posterior a la hora de llegada del avion
s.t. HoraMinima {i in AVIONES, k in PISTAS, t in SLOTS}:
    hora_inicio_slot[k,t] * asignacion_slots[i,k,t] >= hora_programada_llegada[i] * asignacion_slots[i,k,t];
#Restriccion: El inicio del slot de aterrizaje debe ser igual o anterior a la hora limite de aterrizaje del avion
s.t. HoraMaxima {i in AVIONES, k in PISTAS, t in SLOTS}:
    hora_inicio_slot[k,t] * asignacion_slots[i,k,t] <= hora_limite_llegada[i] * asignacion_slots[i,k,t];
#Restriccion: Por cuestiones de seguridad, no se pueden asignar dos slots consecutivos en la misma pista, utilizaremos el parametro num_slots para saber el numero de slots total y utilizaremos 2 aviones para restringir que la llegada no sea consecutiva
s.t. NoSlotsConsecutivos {i in AVIONES, i2 in AVIONES, k in PISTAS, t in SLOTS: i != i2 and t < num_slots}:
    asignacion_slots[i,k,t] + asignacion_slots[i2,k,t+1] <= 1;
#Restricción: Calculamos el retraso de cada avion
s.t. CalculoRetraso {i in AVIONES}:
    retraso[i] = sum {k in PISTAS, t in SLOTS} (hora_inicio_slot[k,t] - hora_programada_llegada[i]) * asignacion_slots[i,k,t];


end;
