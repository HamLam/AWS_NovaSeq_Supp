DROP TABLE IF EXISTS `sample_name_3_random_ref`;
CREATE TABLE `sample_name_3_random_ref` AS
SELECT DISTINCT A1.* FROM
tso_reference A1
JOIN

(SELECT DISTINCT gene_symbol FROM tso_reference_exon WHERE gene_symbol
= 'TP53' OR gene_symbol = 'TOR1A' OR gene_symbol = 'SYNE1') B1
ON(A1.gene_symbol = B1.gene_symbol);

CREATE INDEX `sample_name_3_random_ref_i1` ON `sample_name_3_random_ref`(chr,pos);
CREATE INDEX `sample_name_3_random_ref_i2` ON `sample_name_3_random_ref`(exon_contig_id);
