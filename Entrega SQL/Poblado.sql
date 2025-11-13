INSERT INTO public.usuario(
	nombre_usuario, correo, direccion, "contraseña", nombre_rol, id_cliente)
	VALUES ('Usuario1', 'usuario.1@mail.cl', 'Santiago','123456789', 'cliente', 951);
	
	INSERT INTO public.lista_de_deseados(
	id_lista, id_cliente)
	VALUES (951, 951);

	INSERT INTO public.carrito(
	id_carrito, id_cliente)
	VALUES (951, 951);



	INSERT INTO public.usuario(
	nombre_usuario, correo, direccion, "contraseña", nombre_rol, id_jefe)
	VALUES ('Usuario2', 'usuario.2@mail.cl', 'Valparaiso','password', 'jefe de tienda', 106);

	INSERT INTO public.videojuego(
	urlimagen, fecha_lanzamiento, desarrollador, precio, stock, id_juego, nombre_videojuego, nombre_categoria, id_jefe, ubicacion)
	VALUES ('url.com', '21-11-2010', 'nintendo', 28000, 20, 021, 'Donkey Kong Returns',  'aventura', 106, 'Valparaiso');


    INSERT INTO public.usuario(
	nombre_usuario, correo, direccion, "contraseña", nombre_rol, id_jefe)
	VALUES ('Usuario4', 'usuario.4@mail.cl', 'Santiago','asdfgh', 'jefe de tienda', 601);
    
	INSERT INTO public.videojuego(
	urlimagen, fecha_lanzamiento, desarrollador, precio, stock, id_juego, nombre_videojuego, nombre_categoria, id_jefe, ubicacion)
	VALUES ('url.com', '05-06-2025', 'nintendo', 85000, 70, 365, 'Mario Kart World',  'carreras', 601, 'Santiago');

    INSERT INTO public.videojuego(
	urlimagen, fecha_lanzamiento, desarrollador, precio, stock, id_juego, nombre_videojuego, nombre_categoria, id_jefe, ubicacion)
	VALUES ('url.com', '05-06-2009', 'mojang', 30000, 0, 999, 'Minecraft',  'supervivencia', 601, 'Santiago');

	INSERT INTO public.videojuego(
	urlimagen, fecha_lanzamiento, desarrollador, precio, stock, id_juego, nombre_videojuego, nombre_categoria, id_jefe, ubicacion)
	VALUES ('url.com', '05-06-2016', 'valve', 10000, 9, 111, 'Black Mesa',  'fps', 106, 'Santiago');


INSERT INTO public.usuario(
	nombre_usuario, correo, direccion, "contraseña", nombre_rol, id_cliente)
	VALUES ('Usuario3', 'usuario.3@mail.cl', 'Copiapo','contraseña123', 'cliente', 883);
	
	INSERT INTO public.lista_de_deseados(
	id_lista, id_cliente)
	VALUES (883, 883);

	INSERT INTO public.carrito(
	id_carrito, id_cliente)
	VALUES (883, 883);



	INSERT INTO public.lista_de_deseados(
	id_lista, id_cliente)
	VALUES (855, 855);

	INSERT INTO public.carrito(
	id_carrito, id_cliente)
	VALUES (855, 855);
	
