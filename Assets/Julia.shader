Shader "Explorer/Julia"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Area("Area", vector) = (0, 0, 4, 4)
            _Angle("Angle", range(-3.1415, 3.1415)) = 0
            _MaxIter("Iterations", range(4, 1000)) = 255
            _Color("Color", range(0, 1)) = 0.5
            _Repeat("Repeat", float) = 1
            _Speed("Speed", float) = 1
            _Symmetry("Symmetry", range(0, 1)) = 0
    }

    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 _Area;
            sampler2D _MainTex;
            float _Color, _Repeat, _Speed, _Symmetry, _Angle, _MaxIter;

          float2 rot(float2 pnt, float2 pivot, float a) {
                float s = sin(a);
                float c = cos(a);

                pnt -= pivot;

                pnt = float2(pnt.x * c - pnt.y * s, pnt.x * s + pnt.y * c);

                pnt += pivot;

                return pnt;
           }
      
          fixed4 frag(v2f i) : SV_Target
          {
              float2 uv = i.uv - 0.5;
              
              // 8-fold symmetry
              uv = abs(uv);
              uv = rot(uv, 0, 0.25 * 3.1415);
              uv = abs(uv);

              uv = lerp(i.uv - 0.5, uv, _Symmetry);

                float2 c = _Area.xy + uv*_Area.zw;
                c = rot(c, _Area.xy, _Angle);

                float r = 20;
                float rSquared = r * r;
                float2 z, OldZ;
                float iterator;
                for (iterator = 0; iterator < _MaxIter; iterator++) {
                    OldZ = rot(z, 0, _Time.y);
                    z = float2(z.x * z.x - z.y * z.y, 2 * z.x * z.y) + c;
                    if (dot(z, OldZ) > rSquared) break;
                }
                if (iterator > _MaxIter) {
                    return 0;
                }
                else {
                    // distance from origin
                    float dist = length(z); 
                    
                    // linear interpolation/////
                    float fractalIterations = (dist - r) / (rSquared - r);

                    // exponential interpolation
                    fractalIterations = log2(log(dist) / log(r));
                 
                    
                    
                    float m = sqrt(iterator / _MaxIter);
                    float4 color = sin(float4(0.25, 0.5, 0.75, 1) * m * 20) * 0.5 + 0.5;
                    color = tex2D(_MainTex, float2(m * _Repeat + _Time.y*_Speed, _Color));

                    float angle = atan2(z.x, z.y);
                    color *= smoothstep(3, 0, fractalIterations);

                    color *= 1 + sin(angle * 2 + _Time.y*4) * 0.2;
                    return color;
                }
                
                
                
            }
            ENDCG
        }
    }
}
