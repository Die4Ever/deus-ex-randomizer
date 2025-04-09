#include "common.fxh"
#include "postprocessing.fxh"

static const float3 LUMINANCE_VECTOR  = float3(0.2125f, 0.7154f, 0.0721f);
static const float3 BLUE_SHIFT_VECTOR = float3(1.05f, 0.97f, 1.27f); 
static const float  MIDDLE_GRAY = 0.07f;
static const float  LUM_WHITE = 1.5f;
static const float  BRIGHT_THRESHOLD = 0.6f;

Texture2D luminanceTex;
Texture2D bloomTex;

cbuffer HDRConstants
{
	
}

static const float blurWeights[15] = { 0.15724300, 0.13310331, 0.10082112, 0.068337522, 0.041448805, 0.022496235, 0.010925785,
 0.13298075, //Center texel
    0.15724300, 0.13310331, 0.10082112, 0.068337522, 0.041448805, 0.022496235, 0.010925785};

// static const float blurWeights[27] = { 0.15724300, 0.14517315, 0.13310331, 0.11696221.5, 0.10082112, 0.08457932,
// 0.068337522, 0.054893163, 0.041448805, 0.03197252, 0.022496235, 0.01671101, 0.010925785,
//  0.13298075, //Center texel
//     0.15724300, 0.14517315, 0.13310331, 0.11696221.5, 0.10082112, 0.08457932,
// 0.068337522, 0.054893163, 0.041448805, 0.03197252, 0.022496235, 0.01671101, 0.010925785};

/**
Convert source texture to luminance by taking 3x3 averages
*/
PS_OUTPUT_SIMPLE_R32 PS_sourceToLum(PS_INPUT_SIMPLE input)
{
	PS_OUTPUT_SIMPLE_R32 output = (PS_OUTPUT_SIMPLE_R32)0;
				
	float2 coords = input.pos.xy/viewPort.xy;
	
	float4 vColor = 0.0f;
    float  fAvg = 0.0f;
    
    [unroll] for( int y = -1; y < 1; y++ )
    {
        [unroll] for( int x = -1; x < 1; x++ )
        {
            // Compute the sum of color values
            vColor = inputTexture.Sample(samPointClamp,coords,int2(x,y)); 
            fAvg += dot( vColor.rgb, LUMINANCE_VECTOR );
        }
    }
    
	fAvg /= 5.0;

    output.color = fAvg;
	
	return output;
}

/**
Downscale luminance texture 3x3 times
*/
PS_OUTPUT_SIMPLE_R32 PS_downscaleLum(PS_INPUT_SIMPLE input)
{
	PS_OUTPUT_SIMPLE_R32 output = (PS_OUTPUT_SIMPLE_R32)0;
				
	float2 coords = input.pos.xy/viewPort.xy;
	
    [unroll] for( int y = -1; y < 2; y++ )
    {
        [unroll] for( int x = -1; x < 2; x++ )
        {
            // Compute the sum of color values
             output.color += inputTexture.Sample(samPointClamp,coords,int2(x,y)).r; 
        }
    }
    
	output.color /= 12.3;  // divided by luminance strength (controls light sensitiveness, original value is 12)
	return output;
}

/**
Luminance adaptation
*/
PS_OUTPUT_SIMPLE_R32 PS_calculateAdaptedLum(PS_INPUT_SIMPLE input)
{
	PS_OUTPUT_SIMPLE_R32 output = (PS_OUTPUT_SIMPLE_R32)0;
	float fAdaptedLum = inputTexture.Sample(samPointClamp, float2(0, 0) ).r;
	float fCurrentLum = luminanceTex.Sample(samPointClamp, float2(0, 0) ).r;
	
	// The user's adapted luminance level is simulated by closing the gap between
	// adapted luminance and current luminance by .5% every frame, based on a
	// 30 fps rate. This is not an accurate model of human adaptation, which can
	// take longer than half an hour.
	float fNewAdaptation = fAdaptedLum + (fCurrentLum - fAdaptedLum) * ( 1 - pow( 0.995f, 90 * elapsedTime ) );
    // JC's vision got augmented !
    
    if(fNewAdaptation > 0.060f)  // luminance low limit
        fNewAdaptation = 0.060f;
        
    if(fNewAdaptation < 0.030f)  // luminance high limit
        fNewAdaptation = 0.030f;
    
    output.color = fNewAdaptation;
	
	return output;
}

/**
Bright pass
*/
PS_OUTPUT_SIMPLE PS_brightPass(PS_INPUT_SIMPLE input)
{
	PS_OUTPUT_SIMPLE output = (PS_OUTPUT_SIMPLE)0;
				
	float2 coords = input.pos.xy/viewPort.xy;
	
    float3 vColor = 0.0f;    
    float  fLum = luminanceTex.Sample(samPointClamp, float2(0, 0) ).r;
       
    [unroll] for( int y = -1; y < 2; y++ ) 
    {
        [unroll] for( int x = -1; x < 2; x++ )
        {
            // Compute the sum of color values
            float4 vSample = inputTexture.Sample( samPointClamp, coords, int2(x,y) );                       
            vColor += vSample.rgb;
        }
    }
    
    // Divide the sum to complete the average
    vColor /= 11;    // original value is 9 (controls the bloom min color detection)
 
    // Bright pass and tone mapping
    vColor = max( 0.0f, vColor - BRIGHT_THRESHOLD );
    vColor *= MIDDLE_GRAY / (fLum + 0.001f);
    vColor *= (1.0f + vColor/LUM_WHITE);
    vColor /= (1.0f + vColor);
    
    output.color = float4(vColor, 1.0f);
	return output;
}


/**
Processes the bloom effect
*/
float4 processBloom(Texture2D tex, bool horiz, float2 coords)
{
	float4 result=0;
	float4 vColor;

	[unroll] for( int iSample = 0; iSample < 15; iSample++ )
	{
		// Sample from adjacent points
		int2 offset=int2(3, iSample-7);	// 3 instead of 0 for repositionning
		if(horiz)
			offset.xy=offset.yx;
			
		// new lines added, it reduces the bloom samples offset by dividing it by a value
		offset.xy /= 1.6;
		offset.yx /= 1.6;
		
		vColor = tex.Sample(samClamp, coords, offset);	// changed samPointClamp to samClamp, it looks smoother overall.
        
		result += vColor*blurWeights[iSample] * 0.080; // Change this value to control how strong you want bloom lighting to be
	}

	return result;
}



/**
Gaussian blur
*/
float4 gaussianBlur(Texture2D tex, float2 inputPos, float2 viewPort, bool horiz)
{
	float4 result=0;
	float2 coords;

	// Offset values for bloom lighting

	float2 octoHorOffset1 = float2(-0.004, 0.0);
	float2 octoHorOffset2 = float2(-0.003, 0.0);
	float2 octoHorOffset3 = float2(-0.002, 0.0);
	float2 octoHorOffset4 = float2(-0.001, 0.0);
	float2 octoHorOffset5 = float2(0.001, 0.0);
	float2 octoHorOffset6 = float2(0.002, 0.0);
	float2 octoHorOffset7 = float2(0.003, 0.0);
	float2 octoHorOffset8 = float2(0.004, 0.0);

	float2 octoVertOffset1 = float2(0.0, -0.004);
	float2 octoVertOffset2 = float2(0.0, -0.003);
	float2 octoVertOffset3 = float2(0.0, -0.002);
	float2 octoVertOffset4 = float2(0.0, -0.001);
	float2 octoVertOffset5 = float2(0.0, 0.001);
	float2 octoVertOffset6 = float2(0.0, 0.002);
	float2 octoVertOffset7 = float2(0.0, 0.003);
	float2 octoVertOffset8 = float2(0.0, 0.004);

	float bloomWidth = 1.2;	// Change this value to control how large you want bloom lighting to be
	float2 offsetFix = float2(0.23, 0.23);


	float2 supersampleOffsets[16] = 
	{
		octoHorOffset1, octoHorOffset2, octoHorOffset3, octoHorOffset4, octoHorOffset5, octoHorOffset6, octoHorOffset7, octoHorOffset8,
		octoVertOffset1, octoVertOffset2, octoVertOffset3, octoVertOffset4, octoVertOffset5, octoVertOffset6, octoVertOffset7, octoVertOffset8
	};

	for (int i = 0; i < 16; i++)
	{
		// Resolution independent offsets
		coords = (inputPos + supersampleOffsets[i] * viewPort.x * bloomWidth + offsetFix) / viewPort;
		result += processBloom(tex, horiz, coords);
	}

	return result;
}





PS_OUTPUT_SIMPLE PS_blur_horiz(PS_INPUT_SIMPLE input)
{
	PS_OUTPUT_SIMPLE output = (PS_OUTPUT_SIMPLE)0;

	float2 coords = input.pos.xy/viewPort.xy;
	output.color = gaussianBlur(inputTexture,input.pos.xy,viewPort.xy,true);

	return output;
}

PS_OUTPUT_SIMPLE PS_blur_vert(PS_INPUT_SIMPLE input)
{
	PS_OUTPUT_SIMPLE output = (PS_OUTPUT_SIMPLE)0;

	float2 coords = input.pos.xy/viewPort.xy;
	output.color = gaussianBlur(inputTexture,input.pos.xy,viewPort.xy,false);

	return output;
}



PS_OUTPUT_SIMPLE PS_final(PS_INPUT_SIMPLE input)
{

	

	PS_OUTPUT_SIMPLE output = (PS_OUTPUT_SIMPLE)0;
	float2 coords = input.pos.xy/viewPort.xy;
	output.color = inputTexture.Sample( samPointClamp, coords);
    float vLum = luminanceTex.Sample( samPointClamp, float2(0,0) ).r;
    float4 vBloom = bloomTex.Sample( samClamp, coords );
    
	// Define a linear blending from -1.5 to 2.6 (log scale) which
	// determines the lerp amount for blue shift
    float fBlueShiftCoefficient = 1.0f - (vLum + 1.5)/1.1;
    fBlueShiftCoefficient = saturate(fBlueShiftCoefficient);

	// Lerp between current color and blue, desaturated copy
    float3 vRodColor = dot( (float3)output.color, LUMINANCE_VECTOR ) * BLUE_SHIFT_VECTOR;
    output.color.rgb = lerp( (float3)output.color, vRodColor, fBlueShiftCoefficient );

    // Tone mapping
    output.color.rgb *= MIDDLE_GRAY / (vLum + 0.001f);
    output.color.rgb *= (1.0f + output.color.rgb/LUM_WHITE);
    output.color.rgb /= (1.0f + output.color.rgb);
    
    output.color.rgb += 0.6f * vBloom.rgb;
    output.color.a = 1.0f;
    
	return output;
}

/////////////////////////////////////////////////////////////
//TECHNIQUES
/////////////////////////////////////////////////////////////
technique10 sourceToLum
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_identity() ) );	
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, PS_sourceToLum() ) );
		SetRasterizerState(rstate_NoMSAA);    	
	}
}

technique10 downscaleLum
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_identity() ) );	
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, PS_downscaleLum() ) );
		SetRasterizerState(rstate_NoMSAA);    	
	}
}

technique10 brightPass
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_identity() ) );	
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, PS_brightPass() ) );
		SetRasterizerState(rstate_NoMSAA);    	
	}
}

technique10 blur
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_identity() ) );	
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, PS_blur_horiz() ) );
		SetRasterizerState(rstate_NoMSAA);    	
	}
	pass P1
	{
		SetVertexShader( CompileShader( vs_4_0, VS_identity() ) );	
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, PS_blur_vert() ) );
		SetRasterizerState(rstate_NoMSAA);    	
	}
}

technique10 finalPass
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_identity() ) );	
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, PS_final() ) );
		SetRasterizerState(rstate_NoMSAA);    	
	}
}

technique10 adaptiveLum
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS_identity() ) );	
		SetGeometryShader( 0 );
		SetPixelShader( CompileShader( ps_4_0, PS_calculateAdaptedLum() ) );
		SetRasterizerState(rstate_NoMSAA);    	
	}
}
