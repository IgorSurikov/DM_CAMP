truncate TABLE t_geo_location;
    INSERT INTO t_geo_location (
        level_code,
        country_id,
        country_code_a2,
        country_code_a3,
        country_desc,
        region_id,
        region_code,
        region_desc,
        region_childs,
        part_id,
        part_code,
        part_desc,
        part_childs,
        geo_system_id,
        geo_system_code,
        geo_system_desc,
        geo_system_childs,
        sub_group_id,
        sub_group_code,
        sub_group_desc,
        sub_group_childs,
        group_id,
        group_code,
        group_desc,
        group_childs,
        grp_system_id,
        grp_system_code,
        grp_system_desc,
        group_system_childs
    )
        WITH tree AS (
            SELECT
                temp1.country       country,
                temp1.region        region,
                temp1.continent     continent,
                temp1.geo_system    geo_system,
                temp.country_sub_group,
                temp.country_group,
                temp.group_system
            FROM
                (
                    SELECT
                        lpad(' ', 3 * level)
                        || geo_type_code
                        || child_geo_id                                                                 AS tree,
                        geo_type_code                                                                   AS type,
                        regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 1)            AS group_system,
                        regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 2)            AS country_group,
                        regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 3)            AS country_sub_group,
                        regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 4)            AS country
                    FROM
                        (
                            SELECT
                                l.parent_geo_id                                parent_geo_id,
                                l.child_geo_id                                 child_geo_id,
                                u_dw_references.t_geo_types.geo_type_code      geo_type_code
                            FROM
                                     u_dw_references.t_geo_object_links l
                                INNER JOIN u_dw_references.t_geo_objects t ON l.child_geo_id = t.geo_id
                                INNER JOIN u_dw_references.t_geo_types USING ( geo_type_id )
                            UNION ALL
                            SELECT DISTINCT
                                NULL                                           AS parent_geo_id,
                                parent_geo_id                                  child_geo_id,
                                u_dw_references.t_geo_types.geo_type_code      geo_type_code
                            FROM
                                     u_dw_references.t_geo_object_links
                                INNER JOIN u_dw_references.t_geo_objects t ON parent_geo_id = t.geo_id
                                INNER JOIN u_dw_references.t_geo_types USING ( geo_type_id )
                            WHERE
                                link_type_id = 4
                        )
                    START WITH
                        parent_geo_id IS NULL
                    CONNECT BY
                        PRIOR child_geo_id = parent_geo_id
                    ORDER SIBLINGS BY
                        child_geo_id
                )  temp
                RIGHT JOIN (
                    SELECT
                        lpad(' ', 3 * level)
                        || geo_type_code
                        || child_geo_id                                                                 AS tree,
                        geo_type_code                                                                   AS type,
                        regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 1)            AS geo_system,
                        regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 2)            AS continent,
                        regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 3)            AS region,
                        regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 4)            AS country
                    FROM
                        (
                            SELECT
                                l.parent_geo_id                                parent_geo_id,
                                l.child_geo_id                                 child_geo_id,
                                u_dw_references.t_geo_types.geo_type_code      geo_type_code
                            FROM
                                     u_dw_references.t_geo_object_links l
                                INNER JOIN u_dw_references.t_geo_objects t ON l.child_geo_id = t.geo_id
                                INNER JOIN u_dw_references.t_geo_types USING ( geo_type_id )
                            UNION ALL
                            SELECT DISTINCT
                                NULL                                           AS parent_geo_id,
                                parent_geo_id                                  child_geo_id,
                                u_dw_references.t_geo_types.geo_type_code      geo_type_code
                            FROM
                                     u_dw_references.t_geo_object_links
                                INNER JOIN u_dw_references.t_geo_objects t ON parent_geo_id = t.geo_id
                                INNER JOIN u_dw_references.t_geo_types USING ( geo_type_id )
                            WHERE
                                link_type_id = 1
                        )
                    START WITH
                        parent_geo_id IS NULL
                    CONNECT BY
                        PRIOR child_geo_id = parent_geo_id
                    ORDER SIBLINGS BY
                        child_geo_id
                )  temp1 ON temp.country = temp1.country
            WHERE
                temp1.type = 'COUNTRY'
        )
        SELECT
            'group'                              AS level_code,
            c.country_id                         country_id,
            c.country_code_a2                    country_code_a2,
            c.country_code_a3                    country_code_a3,
            c.country_desc                       country_desc,
            r.region_id                          region_id,
            r.region_code                        region_code,
            r.region_desc                        region_desc,
            COUNT(*)
            OVER(PARTITION BY region_id)         region_childs,
            p.part_id                            part_id,
            p.part_code                          part_code,
            p.part_desc                          part_desc,
            COUNT(DISTINCT region_id)
            OVER(PARTITION BY part_id)           part_childs,
            s.geo_system_id                      geo_system_id,
            s.geo_system_code                    geo_system_code,
            s.geo_system_desc                    geo_system_desc,
            COUNT(DISTINCT part_id)
            OVER(PARTITION BY geo_system_id)     geo_system_childs,
            g.sub_group_id                       sub_group_id,
            g.sub_group_code                     sub_group_code,
            g.sub_group_desc                     sub_group_desc,
            COUNT(*)
            OVER(PARTITION BY sub_group_id)      sub_group_childs,
            g1.group_id                          group_id,
            g1.group_code                        group_code,
            g1.group_desc                        group_desc,
            COUNT(DISTINCT sub_group_id)
            OVER(PARTITION BY group_id)          group_childs,
            g2.grp_system_id                     grp_system_id,
            g2.grp_system_code                   grp_system_code,
            g2.grp_system_desc                   grp_system_desc,
            COUNT(DISTINCT group_id)
            OVER(PARTITION BY grp_system_id)     group_system_childs
        FROM
                 tree
            INNER JOIN u_dw_references.lc_countries             c ON tree.country = c.geo_id
            INNER JOIN u_dw_references.lc_geo_regions           r ON tree.region = r.geo_id
            INNER JOIN u_dw_references.lc_geo_parts             p ON tree.continent = p.geo_id
            INNER JOIN u_dw_references.lc_geo_systems           s ON tree.geo_system = s.geo_id
            INNER JOIN u_dw_references.lc_cntr_sub_groups       g ON tree.country_sub_group = g.geo_id
            INNER JOIN u_dw_references.lc_cntr_groups           g1 ON tree.country_group = g1.geo_id
            INNER JOIN u_dw_references.lc_cntr_group_systems    g2 ON tree.group_system = g2.geo_id
        UNION ALL
        SELECT
            'country'                            AS level_code,
            c.country_id                         country_id,
            c.country_code_a2                    country_code_a2,
            c.country_code_a3                    country_code_a3,
            c.country_desc                       country_desc,
            r.region_id                          region_id,
            r.region_code                        region_code,
            r.region_desc                        region_desc,
            COUNT(*)
            OVER(PARTITION BY region_id)         region_childs,
            p.part_id                            part_id,
            p.part_code                          part_code,
            p.part_desc                          part_desc,
            COUNT(DISTINCT region_id)
            OVER(PARTITION BY part_id)           part_childs,
            s.geo_system_id                      geo_system_id,
            s.geo_system_code                    geo_system_code,
            s.geo_system_desc                    geo_system_desc,
            COUNT(DISTINCT part_id)
            OVER(PARTITION BY geo_system_id)     geo_system_childs,
            NULL                                 sub_group_id,
            NULL                                 sub_group_code,
            NULL                                 sub_group_desc,
            NULL                                 sub_group_childs,
            NULL                                 group_id,
            NULL                                 group_code,
            NULL                                 group_desc,
            NULL                                 group_childs,
            NULL                                 grp_system_id,
            NULL                                 grp_system_code,
            NULL                                 grp_system_desc,
            NULL                                 group_system_childs
        FROM
                 (
                SELECT
                    lpad(' ', 3 * level)
                    || geo_type_code
                    || child_geo_id                                                                 AS tree,
                    geo_type_code                                                                   AS type,
                    regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 1)            AS geo_system,
                    regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 2)            AS continent,
                    regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 3)            AS region,
                    regexp_substr(sys_connect_by_path(child_geo_id, '/'), '[^/]+', 1, 4)            AS country
                FROM
                    (
                        SELECT
                            l.parent_geo_id                                parent_geo_id,
                            l.child_geo_id                                 child_geo_id,
                            u_dw_references.t_geo_types.geo_type_code      geo_type_code
                        FROM
                                 u_dw_references.t_geo_object_links l
                            INNER JOIN u_dw_references.t_geo_objects t ON l.child_geo_id = t.geo_id
                            INNER JOIN u_dw_references.t_geo_types USING ( geo_type_id )
                        UNION ALL
                        SELECT DISTINCT
                            NULL                                           AS parent_geo_id,
                            parent_geo_id                                  child_geo_id,
                            u_dw_references.t_geo_types.geo_type_code      geo_type_code
                        FROM
                                 u_dw_references.t_geo_object_links
                            INNER JOIN u_dw_references.t_geo_objects t ON parent_geo_id = t.geo_id
                            INNER JOIN u_dw_references.t_geo_types USING ( geo_type_id )
                        WHERE
                            link_type_id = 1
                    )
                START WITH
                    parent_geo_id IS NULL
                CONNECT BY
                    PRIOR child_geo_id = parent_geo_id
                ORDER SIBLINGS BY
                    child_geo_id
            ) tree
            INNER JOIN u_dw_references.lc_countries      c ON tree.country = c.geo_id
            INNER JOIN u_dw_references.lc_geo_regions    r ON tree.region = r.geo_id
            INNER JOIN u_dw_references.lc_geo_parts      p ON tree.continent = p.geo_id
            INNER JOIN u_dw_references.lc_geo_systems    s ON tree.geo_system = s.geo_id
        WHERE
            type = 'COUNTRY'