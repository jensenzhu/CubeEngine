{"defaultPrecision":"lowp","variables":[{"usage":2,"variableID":16523841353074928001,"arrayItemCount":1,"precision":"lowp","name":"VertexNormal","type":"vec3"},{"usage":1,"variableID":5204346797065846651,"arrayItemCount":1,"precision":"lowp","name":"NormalMatrix","type":"mat3"},{"usage":1,"variableID":1239578161630753117,"arrayItemCount":1,"precision":"lowp","name":"EyeDirection","type":"vec3"},{"usage":3,"variableID":9223210901354898742,"arrayItemCount":1,"precision":"lowp","name":"LightDirection","type":"vec3"},{"usage":3,"variableID":12204106266451632538,"arrayItemCount":1,"precision":"lowp","name":"EyeDirectionOut","type":"vec3"},{"usage":3,"variableID":5268517760165661644,"arrayItemCount":1,"precision":"lowp","name":"Attenuation","type":"float"},{"usage":3,"variableID":5704507788748658430,"arrayItemCount":1,"precision":"lowp","name":"Normal","type":"vec3"}],"function":{"functionContent":"{\n    #link CEVertex_DirectionLightCalculation(LightDirection, Attenuation);\n    #link CEVertex_PointLightCalculation(LightDirection, Attenuation);\n    #link CEVertex_SpotLightCalculation(LightDirection, Attenuation);\n    EyeDirectionOut = EyeDirection;\n    Normal = normalize(NormalMatrix * VertexNormal);\n    #link CEVertex_ApplyShadowMapp();\n}","linkFunctionDict":{"CEVertex_SpotLightCalculation(vec3,float)":{"paramNames":["LightDirection","Attenuation"],"functionID":"CEVertex_SpotLightCalculation(vec3,float)","linkRange":"{152, 65}"},"CEVertex_DirectionLightCalculation(vec3,float)":{"paramNames":["LightDirection","Attenuation"],"functionID":"CEVertex_DirectionLightCalculation(vec3,float)","linkRange":"{6, 70}"},"CEVertex_ApplyShadowMapp()":{"functionID":"CEVertex_ApplyShadowMapp()","linkRange":"{311, 33}"},"CEVertex_PointLightCalculation(vec3,float)":{"paramNames":["LightDirection","Attenuation"],"functionID":"CEVertex_PointLightCalculation(vec3,float)","linkRange":"{81, 66}"}},"functionID":"CEVertex_ApplyBaseLightEffect()"}}