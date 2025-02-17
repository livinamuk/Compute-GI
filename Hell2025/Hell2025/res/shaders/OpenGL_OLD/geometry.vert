#version 330 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoord;
layout (location = 3) in vec3 aTangent;
layout (location = 4) in ivec4 aBoneID;
layout (location = 5) in vec4 aBoneWeight;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

out vec2 TexCoord;
out vec3 WorldPos;
out vec3 WorldPosPrevious;

out vec3 attrNormal;
out vec3 attrTangent;
out vec3 attrBiTangent;

uniform int tex_flag;

uniform bool isAnimated;
uniform mat4 skinningMats[85];

void main() {

	TexCoord = aTexCoord;

	// ANIMATED 

	if (isAnimated) {
		vec4 totalLocalPos = vec4(0.0);
		vec4 totalNormal = vec4(0.0);
		vec4 totalTangent = vec4(0.0);
			
		vec4 vertexPosition =  vec4(aPos, 1.0);
		vec4 vertexNormal = vec4(aNormal, 0.0);
		vec4 vertexTangent = vec4(aTangent, 0.0);

		for(int i=0;i<4;i++)  {
			mat4 jointTransform = skinningMats[int(aBoneID[i])];
			vec4 posePosition =  jointTransform  * vertexPosition * aBoneWeight[i];
			
			vec4 worldNormal = jointTransform * vertexNormal * aBoneWeight[i];
			vec4 worldTangent = jointTransform * vertexTangent * aBoneWeight[i];

			totalLocalPos += posePosition;		
			totalNormal += worldNormal;	
			totalTangent += worldTangent;	
		}	
		WorldPos = (model * vec4(totalLocalPos.xyz, 1)).xyz;		
		attrNormal =  (model * vec4(normalize(totalNormal.xyz), 0)).xyz;
		attrTangent =  (model * vec4(normalize(totalTangent.xyz), 0)).xyz;
		attrBiTangent = normalize(cross(attrNormal,attrTangent));
	}

	// NOT ANIMATED

	else {	

		mat4 normalMatrix = transpose(inverse(model));
		attrNormal = normalize((normalMatrix * vec4(aNormal, 0)).xyz);
		attrTangent = (model * vec4(aTangent, 0.0)).xyz;
		attrBiTangent = normalize(cross(attrNormal,attrTangent));
		WorldPos = (model * vec4(aPos.x, aPos.y, aPos.z, 1.0)).xyz;	
	}

	gl_Position = projection * view * vec4(WorldPos, 1.0);
}