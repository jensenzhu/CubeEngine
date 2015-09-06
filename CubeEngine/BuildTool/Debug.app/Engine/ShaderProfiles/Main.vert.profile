{"defaultPrecision":"mat4","variables":[{"usage":2,"variableID":15158389945930033855,"arrayItemCount":1,"precision":"highp","name":"VertexPosition","type":"vec4"},{"usage":1,"variableID":11500989196856038453,"arrayItemCount":1,"precision":"mediump","name":"MVPMatrix","type":"mat4"},{"usage":1,"variableID":15250532527401072937,"arrayItemCount":3,"precision":"mediump","name":"colorList","type":"float"}],"function":{"functionContent":"{\n    vec4 inputColor = vec4(1.0);\n    #link CEVertex_TestFunction1(inputColor, colorList);\n    #link CEVertex_TestFunction2();\n    vec3 color = vec3(inputColor);\n    #link CEVertex_TestFunction3(color);\n    gl_Position = MVPMatrix * VertexPosition;\n}","linkFunctionDict":{"CEVertex_TestFunction1(vec4,floatx3)":{"paramNames":["inputColor","colorList"],"functionID":"CEVertex_TestFunction1(vec4,floatx3)","linkRange":"{39, 52}"},"CEVertex_TestFunction2()":{"functionID":"CEVertex_TestFunction2()","linkRange":"{96, 31}"},"CEVertex_TestFunction3(vec3)":{"paramNames":["color"],"functionID":"CEVertex_TestFunction3(vec3)","linkRange":"{167, 36}"}},"functionID":"main()"}}