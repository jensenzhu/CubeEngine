{"defaultPrecision":"lowp","variables":[{"variableID":2204553056974126036,"usage":1,"name":"DiffuseTexture","type":"sampler2D","arrayItemCount":1},{"usage":3,"variableID":11290727296874931951,"arrayItemCount":1,"precision":"mediump","name":"TextureCoordOut","type":"vec2"}],"function":{"functionContent":"{\n    inputColor = texture2D(DiffuseTexture, TextureCoordOut);\n}","paramNames":["inputColor"],"functionID":"CEFrag_ApplyTexture(vec4)","paramLocations":[["{6, 10}"]]}}