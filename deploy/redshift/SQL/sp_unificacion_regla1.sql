-- Orquestador Regla 1
-- Escenario: CALL escenarios R1 en orden
-- Fuente: edf_views → bdm_tempo.v_xpm_* | Salida: bdm_datos.unificacion_direccion
-- Generado: tools/gen_unificacion_sps_por_escenario.py

-- Firma Framework Batch (6 params VARCHAR): in_solicitud, in_nit_suscriptor,
-- in_path_archivo, in_nemotecnico, in_id_facturacion, in_fecha_ejecucion.
-- Los parametros no se usan en la logica de unificacion (procesa edf_views completo).
CREATE OR REPLACE PROCEDURE bdm_datos.sp_unificacion_regla1(
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

  CALL bdm_datos.sp_unificacion_r1_preparar_insumo();
  CALL bdm_datos.sp_unificacion_r1_esc1_ciiu10_mismo_texto_padre_lab_crr();
  CALL bdm_datos.sp_unificacion_r1_esc2_ciiu81_90_mismo_texto_padre_res_crr();
  CALL bdm_datos.sp_unificacion_r1_esc3_otros_ciiu_mayor_entidades_reportan();
  DROP TABLE IF EXISTS bdm_tempo.stg_regla1_insumo;

EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION 'sp_unificacion_regla1 failed: %', SQLERRM;
END;
$$;
