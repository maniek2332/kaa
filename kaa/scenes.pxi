from libc.stdint cimport uint32_t
from libcpp.memory cimport unique_ptr
from cpython.ref cimport PyObject, Py_INCREF, Py_DECREF
from cpython.weakref cimport PyWeakref_NewRef

from .kaacore.nodes cimport CNodePtr
from .kaacore.scenes cimport CScene
from .kaacore.engine cimport is_c_engine_initialized
from .kaacore.log cimport c_log_dynamic, CLogCategory, CLogLevel


cdef cppclass CPyScene(CScene):
    object py_scene_weakref

    __init__(object py_scene):
        c_log_dynamic(CLogLevel.debug, CLogCategory.engine,
                    'Created CPyScene')
        this.py_scene_weakref = PyWeakref_NewRef(py_scene, None)

    object get_py_scene():
        cdef object py_scene = this.py_scene_weakref()
        if py_scene is None:
            raise RuntimeError(
                'Tried to retrieve scene which was already destroyed.'
            )
        return py_scene

    void on_attach() nogil:
        with gil:
            Py_INCREF(this.get_py_scene())

    void on_enter() nogil:
        with gil:
            try:
                this.get_py_scene().on_enter()
            except BaseException as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)

    void update(uint32_t dt) nogil:
        with gil:
            try:
                this.get_py_scene().update(dt)
            except BaseException as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)

    void on_exit() nogil:
        with gil:
            try:
                this.get_py_scene().on_exit()
            except BaseException as py_exc:
                c_wrap_python_exception(<PyObject*>py_exc)

    void on_detach() nogil:
        with gil:
            Py_DECREF(this.get_py_scene())


cdef class Scene:
    cdef:
        object __weakref__
        unique_ptr[CPyScene] _c_scene
        Node py_root_node_wrapper
        InputManager input_
        readonly ViewsManager views

    def __cinit__(self):
        if not is_c_engine_initialized():
            raise RuntimeError(
                'Cannot create scene since engine is not initialized yet.'
            )

        c_log_dynamic(
            CLogLevel.debug, CLogCategory.engine, 'Initializing Scene'
        )
        cdef CPyScene* c_scene = new CPyScene(self)
        assert c_scene != NULL
        self._c_scene = unique_ptr[CPyScene](c_scene)

        self.views = ViewsManager.create(&self._c_scene.get().views)
        self.py_root_node_wrapper = get_node_wrapper(CNodePtr(&self._c_scene.get().root_node))
        self.input_ = InputManager()

    def __dealloc__(self):
        self.views._mark_invalid()

    def on_enter(self):
        pass

    def update(self, dt):
        raise NotImplementedError

    def on_exit(self):
        pass

    @property
    def engine(self):
        return get_engine()
    
    @property
    def camera(self):
        return self.views[0].camera
    
    @property
    def clear_color(self):
        return self.views[0].clear_color

    @clear_color.setter
    def clear_color(self, Color color):
        self.views[0].clear_color = color

    @property
    def input(self):
        return self.input_

    @property
    def root(self):
        return self.py_root_node_wrapper
