-- Orquestador Regla 2
-- Escenario: CALL escenarios R2 en orden
-- Fuente: edf_views → bdm_tempo.v_xpm_* | Salida: bdm_datos.unificacion_direccion
-- Generado: tools/gen_unificacion_sps_por_escenario.py

-- Firma Framework Batch (6 params VARCHAR): in_solicitud, in_nit_suscriptor,
-- in_path_archivo, in_nemotecnico, in_id_facturacion, in_fecha_ejecucion.
-- Los parametros no se usan en la logica de unificacion (procesa edf_views completo).
CREATE OR REPLACE PROCEDURE bdm_datos.sp_unificacion_regla2(
    in_solicitud       VARCHAR,
    in_nit_suscriptor  VARCHAR,
    in_path_archivo    VARCHAR,
    in_nemotecnico     VARCHAR,
    in_id_facturacion  VARCHAR,
    in_fecha_ejecucion VARCHAR
)
NONATOMIC
LANGUAGE plpgsql
AS $$
BEGIN

  CALL bdm_datos.sp_unificacion_r2_preparar_insumo();
  CALL bdm_datos.sp_unificacion_r2_esc1_complemento_vacio_esc2_substring_complemento();
  CALL bdm_datos.sp_unificacion_r2_esc3_sin_nit_misma_nomenclatura();
  CALL bdm_datos.sp_unificacion_r2_esc4_diccionario_frecuencia_complemento();
  CALL bdm_datos.sp_unificacion_r2_esc5_nomenclatura_menor_nivel_pierde();
  CALL bdm_datos.sp_unificacion_r2_esc6_frecuencia_complemento_gana();
  CALL bdm_datos.sp_unificacion_r2_motor_nit_empates_nuevas_direcciones();

  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_insumo;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_esc1_pares;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e1;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_esc2_pares;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e2;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e03;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e03_a;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e03_e1;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e04;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e04_a;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e04_c1;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e04_ganador;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e04_e;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e05;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e05_a;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e05_pares;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e06_freq;
  DROP TABLE IF EXISTS bdm_tempo.stg_regla2_e06_pares;
  DROP TABLE IF EXISTS bdm_tempo.stg_motor_keys;
  DROP TABLE IF EXISTS bdm_tempo.stg_motor_ranked;
  DROP TABLE IF EXISTS bdm_tempo.stg_motor_insumo;

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'sp_unificacion_regla2 failed: %', SQLERRM;
END;
$$;
