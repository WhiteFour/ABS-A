Shader "Unlit/UIshader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
	_Color("Color",Color) = (1,1,1,1)
		_Cscale("_Cscale",Range(0,50000)) = 1
		_CscaleY("_CscaleY",Range(0,50000)) = 1
    }
    SubShader
    {
        Tags { "QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" }        
        ZWrite Off
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

           /* struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };*/

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			half4 _Color;
			float _Cscale;
			float _CscaleY;
            float4 _MainTex_ST;

            v2f vert (appdata_full  v)
            {
                v2f o;
				float time = _Time * _Cscale;
				float waveValueA = sin(time + v.vertex * _Cscale) * 10;
				  
				v.vertex.xyz = float3(v.vertex.x , v.vertex.y + waveValueA,
					v.vertex.z);
 

				v.normal = normalize(float3(v.normal.x + waveValueA, v.normal.y,
					v.normal.z));
				 //o.vertColor = float3(waveValueA, waveValueA, waveValueA);
                o.vertex = UnityObjectToClipPos(v.vertex);
				
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				 
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
			    col.xyz = _Color * _Cscale *10;
				if (i.uv.y > 0.55&&i.uv.y < 0.6) {					 
					col.xyz = 0;			
				}
				if (_Cscale == 0) {
					col.a = 0;
				}
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
