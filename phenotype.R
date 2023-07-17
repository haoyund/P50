library(bigrquery)
library(lubridate)
library(tidyverse)

formulate_and_run_multipart_query <- function(subqueries, final_tbl) {
    query <- str_c('WITH\n', str_c(subqueries, collapse = ',\n\n'), str_glue('\n\n\nSELECT * FROM {final_tbl}'))
    message(query)               
    results <- bq_table_download(bq_dataset_query(Sys.getenv('WORKSPACE_CDR'),
                                                  query,
                                                  billing = Sys.getenv('GOOGLE_PROJECT')),
                                 bigint = 'integer64')
    message(str_glue('Dimensions of result: num_rows={nrow(results)} num_cols={ncol(results)}'))
    return(results)
}

DATESTAMP <- strftime(now(), '%Y%m%d')
DESTINATION <- str_glue('{Sys.getenv("WORKSPACE_BUCKET")}/data/aou/pheno/{DATESTAMP}/')
AOU_PHENOTYPE_FILENAME <- 'opioid_phenotype.csv'
AOU_ID_FILENAME <- 'opioid_ids.tsv'

COHORT_QUERY <- '
-- This query represents dataset "Demographics for AoU srWGS cohort" for domain "person"
cohort_tbl AS (
    SELECT person_id from `cb_search_person` cb_search_person
    WHERE cb_search_person.person_id in (
        SELECT person_id FROM `cb_search_person` p
        WHERE has_whole_genome_variant = 1)
)'
