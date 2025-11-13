--consulta 1
INSERT INTO usuario(
	nombre_usuario, correo, direccion, "contraseña", nombre_rol, id_jefe)
	VALUES ('Pedro Garcia', 'pedro.garcia@mail.cl', 'Santiago', 'password', 'jefe de tienda', 470);
	
--consulta 2
INSERT INTO usuario(
	nombre_usuario, correo, nombre_rol)
	VALUES ('Maria Garcia', NULL, 'cliente');

--consulta 3
INSERT INTO usuario(
	nombre_usuario, correo, nombre_rol)
	VALUES ('Juana Garcia', 'juana.garcia@mail.cl', 'mago');

--consulta 4
INSERT INTO usuario(
	nombre_usuario, correo, direccion, "contraseña", nombre_rol, id_cliente)
	VALUES ('Camila Rojas', 'camila.rojas@mail.cl', 'Santiago', '12345', 'cliente', 855);

--consulta 5
INSERT INTO videojuego(
	urlimagen, precio, stock, id_juego, nombre_videojuego)
	VALUES ('urlvalida.com', 25000, -3, 123, 'Zelda');

--consulta 6
INSERT INTO videojuego(
	urlimagen, precio, stock, id_juego, nombre_videojuego, nombre_categoria)
	VALUES ('urlvalida.com', 25000, 5, 123, 'Zelda', 'deporte extremo');

--consulta 7
INSERT INTO videojuego(
	urlimagen, fecha_lanzamiento, desarrollador, precio, stock, id_juego, nombre_videojuego, nombre_categoria, id_jefe, ubicacion)
	VALUES ('urlvalida.com', '23-5-2003', 'nintendo', 25000, 5, 339, 'Zelda', 'aventura', 470, 'Santiago');

--consulta 8
UPDATE videojuego
	SET urlimagen='zelda_nueva.com', precio=30000, stock=10
	WHERE nombre_videojuego='Zelda' AND id_jefe=470

--consulta 9
select agregar_a_lista_deseados(855,339)

--consulta 10
select agregar_a_lista_deseados(855,339)

--consulta 11
select * from mostrar_lista_deseados(855)

--consulta 12
select agregar_carrito(855,339,1)

--consulta 13
select * from mostrar_carrito(855)

--consulta 14
select * from total_carrito(855)

--consulta 15
select eliminar_carrito(855,339)

--consulta 16
select agregar_carrito(855,339,1)

--consulta 17
select agregar_carrito(855,339,999)

--consulta 18
select agregar_carrito(855,999,0)

--consulta 19
select compra(855)

--consulta 20
--consulta 21
--consulta 22


--consulta 23
select * from top3()

--consulta 24
SELECT id_juego AS id_juego, COUNT(*) AS cantidad_deseos
FROM lista_videojuegos
GROUP BY id_juego
ORDER BY cantidad_deseos DESC;

--consulta 25
SELECT *FROM videojuego
WHERE ubicacion = 'Santiago';

--consulta 26
SELECT id_juego, COUNT(*) AS cantidad_ventas
FROM orden_juego
GROUP BY id_juego
ORDER BY cantidad_ventas DESC;

--consulta 27
SELECT DISTINCT v.id_juego, v.nombre_videojuego, v.precio, v.stock, v.ubicacion
FROM usuario u
JOIN videojuego v ON u.direccion = v.ubicacion
WHERE u.direccion = 'Santiago';

--consulta 28
insert into videojuego (id_juego, nombre_videojuego, precio, stock, nombre_categoria)
	values (100, 'Titulo', 45000, 20, 'aventura');

	select * from log_videojuego;

--consulta 29
update videojuego set stock = 1 where id_juego=100;
select * from log_actualizacion_videojuego

--consulta 30
delete from videojuego where id_juego=339

--consulta 31
 CALL actualizar_precio_categoria('aventura', 10);

--consulta 32
select * from reporte_ventas_usuario(855);
