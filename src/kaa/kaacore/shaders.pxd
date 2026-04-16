from libcpp.string cimport string
from libcpp.unordered_map cimport unordered_map

from .exceptions cimport raise_py_error
from .resources cimport CResourceReference


cdef extern from "kaacore/shaders.h" namespace "kaacore" nogil:

    cdef enum CShaderType "kaacore::ShaderType":
        vertex "kaacore::ShaderType::vertex"
        fragment "kaacore::ShaderType::fragment"

    cdef enum CShaderModel "kaacore::ShaderModel":
        hlsl_dxbc "kaacore::ShaderModel::hlsl_dxbc"
        hlsl_dxil "kaacore::ShaderModel::hlsl_dxil"
        glsl "kaacore::ShaderModel::glsl"
        spirv "kaacore::ShaderModel::spirv"
        metal "kaacore::ShaderModel::metal"
        unknown "kaacore::ShaderModel::unknown"

    ctypedef unordered_map[CShaderModel, string] CShaderModelMap \
        "kaacore::ShaderModelMap"

    cdef cppclass CShader "kaacore::Shader":
        @staticmethod
        CResourceReference[CShader] load(
            const CShaderType type_,
            const CShaderModelMap& model_map
        ) except +raise_py_error
        CShaderType type()

    cdef cppclass CProgram "kaacore::Program":
        CResourceReference[CShader] vertex_shader
        CResourceReference[CShader] fragment_shader

        @staticmethod
        CResourceReference[CProgram] create(
            const CResourceReference[CShader] vertex,
            const CResourceReference[CShader] fragment
        ) except +raise_py_error
