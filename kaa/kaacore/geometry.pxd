from libcpp.vector cimport vector

from .vectors cimport CVector


cdef extern from "kaacore/geometry.h" nogil:
    cdef enum CPolygonType "kaacore::PolygonType":
        convex_cw "kaacore::PolygonType::convex_cw",
        convex_ccw "kaacore::PolygonType::convex_ccw",
        not_convex "kaacore::PolygonType::not_convex",

    cdef enum CAlignment "kaacore::Alignment":
        none "kaacore::Alignment::none"
        top "kaacore::Alignment::top"
        bottom "kaacore::Alignment::bottom"
        left "kaacore::Alignment::left"
        right "kaacore::Alignment::right"
        top_left "kaacore::Alignment::top_left"
        bottom_left "kaacore::Alignment::bottom_left"
        top_right "kaacore::Alignment::top_right"
        bottom_right "kaacore::Alignment::bottom_right"
        center "kaacore::Alignment::center"

    CPolygonType c_classify_polygon "kaacore::classify_polygon"(const vector[CVector]& points)