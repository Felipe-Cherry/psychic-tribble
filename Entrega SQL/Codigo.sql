CREATE TABLE IF NOT EXISTS tipo_de_usuario
(
    nombre_rol character varying(14) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "TipoUsuarios_pkey" PRIMARY KEY (nombre_rol),
    CONSTRAINT tipo_de_usuario_nombre_rol_check CHECK (nombre_rol::text = 'cliente'::text OR nombre_rol::text = 'admin'::text OR nombre_rol::text = 'jefe de tienda'::text) NOT VALID
);


CREATE TABLE IF NOT EXISTS usuario
(
    nombre_usuario character varying(16) COLLATE pg_catalog."default" NOT NULL,
    correo character varying COLLATE pg_catalog."default" NOT NULL,
    direccion character varying COLLATE pg_catalog."default",
    "contraseña" character varying(16) COLLATE pg_catalog."default",
    nombre_rol character varying(14) COLLATE pg_catalog."default" NOT NULL,
    id_cliente bigint,
    id_jefe bigint,
    CONSTRAINT "Usuario_pkey" PRIMARY KEY (nombre_usuario),
    CONSTRAINT id_cliente UNIQUE (id_cliente),
    CONSTRAINT id_jefe UNIQUE (id_jefe),
    CONSTRAINT "nombreRol" FOREIGN KEY (nombre_rol)
        REFERENCES tipo_de_usuario (nombre_rol) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID 
);

CREATE TABLE IF NOT EXISTS categoria
(
    nombre_categoria character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT "Categoria_pkey" PRIMARY KEY (nombre_categoria),
    CONSTRAINT categoria_nombre_categoria_check CHECK (nombre_categoria::text = 'carreras'::text OR nombre_categoria::text = 'aventura'::text OR nombre_categoria::text = 'fps'::text OR nombre_categoria::text = 'supervivencia'::text) NOT VALID
);


CREATE TABLE IF NOT EXISTS videojuego
(
    urlimagen character varying COLLATE pg_catalog."default",
    fecha_lanzamiento date,
    desarrollador character varying COLLATE pg_catalog."default",
    precio bigint NOT NULL,
    stock bigint NOT NULL,
    id_juego bigint NOT NULL,
    nombre_videojuego character varying COLLATE pg_catalog."default" NOT NULL,
    nombre_categoria character varying COLLATE pg_catalog."default",
    id_jefe bigint,
    ubicacion character varying COLLATE pg_catalog."default",
    CONSTRAINT "Videojuego_pkey" PRIMARY KEY (id_juego),
    CONSTRAINT id_jefe FOREIGN KEY (id_jefe)
        REFERENCES usuario (id_jefe) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT nombre_categoria FOREIGN KEY (nombre_categoria)
        REFERENCES categoria (nombre_categoria) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "Copias" CHECK (stock >= 0) NOT VALID
);

CREATE TABLE IF NOT EXISTS valoracion
(
    "IdValoracion" bigint NOT NULL,
    "Puntaje" bigint NOT NULL,
    "Comentario" character varying COLLATE pg_catalog."default",
    id_cliente bigint,
    CONSTRAINT "Valoracion_pkey" PRIMARY KEY ("IdValoracion"),
    CONSTRAINT valoracion_id_cliente_fkey FOREIGN KEY (id_cliente)
        REFERENCES usuario (id_cliente) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID,
    CONSTRAINT "Puntos" CHECK ("Puntaje" >= 0 AND "Puntaje" < 11)
);

	CREATE TABLE IF NOT EXISTS carrito
(
    id_carrito integer NOT NULL,
    id_cliente bigint,
    CONSTRAINT "Carrito_pkey" PRIMARY KEY (id_carrito),
    CONSTRAINT carrito_id_cliente_fkey FOREIGN KEY (id_cliente)
        REFERENCES usuario (id_cliente) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

CREATE TABLE IF NOT EXISTS orden
(
    id_orden bigint NOT NULL,
    boleta character varying COLLATE pg_catalog."default",
    metodo_pago character varying COLLATE pg_catalog."default",
    monto_total bigint,
    fecha_orden date,
    id_carrito bigint,
    CONSTRAINT "Orden_pkey" PRIMARY KEY (id_orden),
    CONSTRAINT orden_id_carrito_fkey FOREIGN KEY (id_carrito)
        REFERENCES carrito (id_carrito) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);



CREATE TABLE IF NOT EXISTS orden_juego
(
    id_orden bigint NOT NULL,
    id_juego bigint NOT NULL,
    CONSTRAINT "IdJuego" FOREIGN KEY (id_juego)
        REFERENCES videojuego (id_juego) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "IdOrden" FOREIGN KEY (id_orden)
        REFERENCES orden (id_orden) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS lista_de_deseados
(
    id_lista bigint NOT NULL,
    id_cliente bigint NOT NULL,
    CONSTRAINT "ListaDeseados_pkey" PRIMARY KEY (id_lista),
    CONSTRAINT lista_de_deseados_id_cliente_fkey FOREIGN KEY (id_cliente)
        REFERENCES usuario (id_cliente) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
);

CREATE TABLE IF NOT EXISTS lista_videojuegos
(
    id_lista bigint NOT NULL,
    id_juego bigint NOT NULL,
    CONSTRAINT lista_videojuegos_pkey PRIMARY KEY (id_lista, id_juego),
    CONSTRAINT lista_videojuegos_id_juego_fkey FOREIGN KEY (id_juego)
        REFERENCES videojuego (id_juego) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lista_videojuegos_id_lista_fkey FOREIGN KEY (id_lista)
        REFERENCES lista_de_deseados (id_lista) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);





CREATE TABLE IF NOT EXISTS carrito_juego
(
    id_carrito bigint NOT NULL,
    id_juego bigint NOT NULL,
    cantidad bigint,
    CONSTRAINT carrito_juego_id_carrito_fkey FOREIGN KEY (id_carrito)
        REFERENCES carrito (id_carrito) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT carrito_juego_id_juego_fkey FOREIGN KEY (id_juego)
        REFERENCES videojuego (id_juego) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT carrito_juego_cantidad_check CHECK (cantidad >= 0) NOT VALID
);

CREATE OR REPLACE FUNCTION validar_stock()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
declare stock_disponible bigint;
begin
select stock into stock_disponible
from videojuego
where id_juego = new.id_juego;

if new.cantidad >stock_disponible then
RAISE EXCEPTION 'No se puede añadir % unidades: solo hay % en stock.',
new.cantidad,stock_disponible;
end if;
return new;
end;
$BODY$;

CREATE OR REPLACE TRIGGER tr_validar_stock
    BEFORE INSERT OR UPDATE 
    ON carrito_juego
    FOR EACH ROW
    EXECUTE FUNCTION validar_stock();


CREATE OR REPLACE FUNCTION agregar_carrito(
	id_cliente_param bigint,
	id_juego_param bigint,
	cantidad_param bigint)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare
carrito_id int;
stock_actual bigint;
cantidad_existente bigint;
begin

select id_carrito into carrito_id
from carrito
where id_cliente=id_cliente_param;

select  stock into stock_actual
from videojuego
where id_juego=id_juego_param;

select cantidad into cantidad_existente
from carrito_juego
where id_juego=id_juego_param;

if found then
  if cantidad_existente + cantidad_param >stock_actual
  then
  raise exception
  'No se pueden añadir % unidades. Stock disponible: %',
  cantidad_param,stock_actual - cantidad_existente;
  end if;

  update carrito_juego
  set cantidad=cantidad+cantidad_param
  where id_carrito = carrito_id
   and id_juego=id_juego_param;

  raise notice 'Se agrego el producto al carrito';
 else

 if cantidad_param > stock_actual then
  raise exception 'No se pueden añadir % unidades. Stock disponible: %',
  cantidad_param,stock_actual;
  end if;

  insert into carrito_juego(id_carrito,id_juego,cantidad)
  values (carrito_id,id_juego_param,cantidad_param);

  raise notice 'Se agrego el producto al carrito';
  end if;
end;
$BODY$;

CREATE OR REPLACE FUNCTION eliminar_carrito(
	id_cliente_param bigint,
	id_juego_param bigint)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare
  carrito_id int;
  borrado int;
begin
  select id_carrito into carrito_id
  from carrito
  where id_cliente=id_cliente_param;

  delete from carrito_juego
  where id_carrito=carrito_id and id_juego=id_juego_param;

  raise notice 'producto eliminado del carrito';
end;
$BODY$;


CREATE OR REPLACE FUNCTION mostrar_carrito(
	id_cliente_param bigint)
    RETURNS TABLE(nombre_videojuego character varying, precio bigint, cantidad bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
begin
 return query
 select v.nombre_videojuego,v.precio,cj.cantidad
 from carrito c join carrito_juego cj on c.id_carrito=cj.id_carrito
 join videojuego v on v.id_juego=cj.id_juego
 where c.id_cliente=id_cliente_param;
end;
$BODY$;


CREATE OR REPLACE FUNCTION total_carrito(
	id_cliente_param bigint)
    RETURNS bigint
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare total bigint; carrito_id int;
begin
select id_carrito into carrito_id
from carrito
where id_cliente = id_cliente_param;

SELECT SUM(v.precio * cj.cantidad)
into total
From carrito_juego cj join videojuego v on v.id_juego=cj.id_juego
where cj.id_carrito = carrito_id;

return coalesce(total, 0);

end;
$BODY$;


CREATE OR REPLACE FUNCTION top3(
	)
    RETURNS TABLE(id_juego bigint, nombre_videojuego character varying, total_ventas bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
begin
    return query
    select
        v.id_juego,
        v.nombre_videojuego,
        count(oj.id_juego) as total_ventas
    from orden_juego oj
    join videojuego v on v.id_juego = oj.id_juego
    group by v.id_juego, v.nombre_videojuego
    order by total_ventas desc
    limit 3;
end;
$BODY$;


CREATE OR REPLACE FUNCTION mostrar_lista_deseados(
	id_cliente_param bigint)
    RETURNS TABLE(nombre_videojuego character varying, precio bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
begin
     return query
	 select
	 v.nombre_videojuego,
	 v.precio
	 FROM lista_de_deseados ld join lista_videojuegos lv on ld.id_lista=lv.id_lista 
	 join videojuego v on v.id_juego=lv.id_juego
	 where ld.id_cliente=id_cliente_param;
end;
$BODY$;


CREATE OR REPLACE FUNCTION compra(
	id_cliente_param bigint)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare carrito_id int;
        nueva_orden_id bigint;
		precio_total bigint;
		nombres_videojuegos text;
begin

  select id_carrito into carrito_id
  from carrito
  where id_cliente = id_cliente_param;

  if not exists(select 1 from carrito_juego where id_carrito = carrito_id)
  then
  raise exception 'El carrito esta vacio.';
  end if;

  if exists(select 1
            from carrito_juego cj join videojuego v on v.id_juego=cj.id_juego
			where cj.id_carrito=carrito_id and cj.cantidad > v.stock)
			then 
			raise exception 'No hay stock disponible';
			end if;

			select coalesce(max(id_orden),0)+ 1 into nueva_orden_id
			from orden;

            select string_agg(v.nombre_videojuego, ', ') into nombres_videojuegos
            from carrito_juego cj
            join videojuego v on v.id_juego = cj.id_juego
            where cj.id_carrito = carrito_id;

			insert into orden (id_orden,boleta,metodo_pago,monto_total,fecha_orden,id_carrito)
			values (nueva_orden_id, nombres_videojuegos, 'Tarjeta', 0, current_date, carrito_id);

			 insert into orden_juego (id_orden, id_juego)
             select nueva_orden_id, id_juego
             from carrito_juego
             where id_carrito = carrito_id;

			 update videojuego v
             set stock = stock - cj.cantidad
             from carrito_juego cj
             where v.id_juego = cj.id_juego
             and cj.id_carrito = carrito_id;

			 select sum(v.precio * cj.cantidad)
             into precio_total
             from carrito_juego cj
             join videojuego v on v.id_juego = cj.id_juego
             where cj.id_carrito = carrito_id;

			 update orden
             set monto_total = precio_total
             where id_orden = nueva_orden_id;

			 delete from carrito_juego
             where id_carrito = carrito_id;

			 raise notice 'Compra completada exitosamente. Orden ID: %    Boleta: %', nueva_orden_id,nombres_videojuegos;
END;
$BODY$;

CREATE OR REPLACE FUNCTION agregar_a_lista_deseados(
	id_cliente_param bigint,
	id_juego_param bigint)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    lista_id BIGINT;
BEGIN
    SELECT id_lista INTO lista_id
    FROM lista_de_deseados
    WHERE id_cliente = id_cliente_param;

    IF lista_id IS NULL THEN
        RAISE EXCEPTION 'El usuario con ID % no tiene una lista de deseados.', id_cliente_param;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM lista_videojuegos
        WHERE id_lista = lista_id
          AND id_juego = id_juego_param
    ) THEN
        RAISE exception 'llave duplicada viola restricción de unicidad «lista_videojuegos_pkey»
Ya existe la llave (id_lista, id_juego)=(%, %).
',
            id_juego_param, id_cliente_param;
        RETURN;
    END IF;

    INSERT INTO lista_videojuegos(id_lista, id_juego)
    VALUES (lista_id, id_juego_param);

    RAISE NOTICE 'Videojuego con ID % añadido a la lista de deseados del cliente %.',
        id_juego_param, id_cliente_param;

END;
$BODY$;

CREATE OR REPLACE PROCEDURE actualizar_precio_categoria(
    categoria_input VARCHAR,
    porcentaje_aumento NUMERIC)
LANGUAGE plpgsql
AS 
$$
BEGIN
    UPDATE videojuego
    SET precio = precio + (precio * (porcentaje_aumento / 100.0))
    WHERE nombre_categoria = categoria_input;
END;
$$;



CREATE OR REPLACE FUNCTION reporte_ventas_usuario(cliente_id BIGINT)
RETURNS TABLE (id_orden BIGINT, nombre_videojuego VARCHAR, fecha DATE, monto BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.id_orden,
        v.nombre_videojuego,
        o.fecha_orden,
        o.monto_total
    FROM 
        usuario u
    JOIN carrito c ON u.id_cliente = c.id_cliente
    JOIN orden o ON c.id_carrito = o.id_carrito
    JOIN orden_juego oj ON o.id_orden = oj.id_orden
    JOIN videojuego v ON oj.id_juego = v.id_juego
    WHERE u.id_cliente = cliente_id;
END;
$$;

CREATE TABLE log_videojuego (
    id_log SERIAL PRIMARY KEY,
    id_juego BIGINT,
    nombre_videojuego VARCHAR,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION registrar_insercion_videojuego()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_videojuego (id_juego, nombre_videojuego)
    VALUES (NEW.id_juego, NEW.nombre_videojuego);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_insercion_videojuego
AFTER INSERT ON videojuego
FOR EACH ROW
EXECUTE FUNCTION registrar_insercion_videojuego();

CREATE TABLE log_actualizacion_videojuego (
    id_log SERIAL PRIMARY KEY,
    id_juego BIGINT,
    nombre_anterior VARCHAR,
    nombre_nuevo VARCHAR,
    precio_anterior BIGINT,
    precio_nuevo BIGINT,
    stock_anterior BIGINT,
    stock_nuevo BIGINT,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION registrar_actualizacion_videojuego()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_actualizacion_videojuego (
        id_juego,
        nombre_anterior,
        nombre_nuevo,
        precio_anterior,
        precio_nuevo,
        stock_anterior,
        stock_nuevo
    )
    VALUES (
        OLD.id_juego,
        OLD.nombre_videojuego,
        NEW.nombre_videojuego,
        OLD.precio,
        NEW.precio,
        OLD.stock,
        NEW.stock
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_actualizacion_videojuego
AFTER UPDATE ON videojuego
FOR EACH ROW
EXECUTE FUNCTION registrar_actualizacion_videojuego();



CREATE OR REPLACE FUNCTION impedir_eliminacion_si_comprado()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si el videojuego ha sido comprado
    IF EXISTS (
        SELECT 1
        FROM orden_juego
        WHERE id_juego = OLD.id_juego
    ) THEN
        RAISE EXCEPTION 'No se puede eliminar el videojuego con ID % porque ya ha sido comprado.', OLD.id_juego;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_impedir_eliminar_videojuego
BEFORE DELETE ON videojuego
FOR EACH ROW
EXECUTE FUNCTION impedir_eliminacion_si_comprado();

