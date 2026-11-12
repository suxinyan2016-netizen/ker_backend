package com.issrv.radar.util;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;

public final class GeometryUtils {

    // SRID 0 与 events.location_geo 列及 Python 写入保持一致；混用 4326 会导致空间函数 SRID 不匹配
    private static final GeometryFactory FACTORY = new GeometryFactory(new PrecisionModel(), 0);

    private GeometryUtils() {
    }

    /** X=经度, Y=纬度 */
    public static Point createPoint(double lng, double lat) {
        if (lng < -180 || lng > 180 || lat < -90 || lat > 90) {
            throw new IllegalArgumentException("Invalid coordinates: lng=" + lng + ", lat=" + lat);
        }
        return FACTORY.createPoint(new Coordinate(lng, lat));
    }
}