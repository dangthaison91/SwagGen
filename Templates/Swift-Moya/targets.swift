{% include "Includes/header.stencil" %}

import Foundation
import Alamofire
import Moya

struct {% if name %}{{ name|upperCamelCase }}{% else %}{{ options.name }}{% endif %}Targets {
    {% for operation in operations %}

    {% if operation.description %}
    /**
    {{ operation.description }}
    {% if operation.responses %}
    - returns: {{ operation.singleSuccessType }}
    - JSON: {{ operation.successResponse }}
    {% endif %}
    */
    {% endif %}

    {% for enum in enums %}
    {% if not enum.isGlobal %}

    {% include "Includes/enum.stencil" using enum %}
    {% endif %}
    {% endfor %}
    {% if operation.bodyParam.anonymousSchema %}
    {% include "Includes/Model.stencil" using operation.bodyParam %}

    {% endif %}
    struct {{ operation.operationId|upperCamelCase }}Target: APITargetType {
        let method: Moya.Method = .{{ operation.method|lowercase }}
        {%if not operation.pathParams %}

        let path: String = "{{ operation.path }}"
        {% else %}

        var path: String {
            let targetPath: String = "{{ operation.path }}"
            return targetPath
            {% for param in operation.pathParams %}
                .replacingOccurrences(of: "{{ param.value }}", with: "\({{ param.name }})")
            {% endfor %}
        }

        {% endif %}
        {% if operation.hasFileParam %}
        var task: Task {
            var formData: [Moya.MultipartFormData] = []
            {% for param in operation.formParams where param.isFile %}
            let {{param.name}}Data = Moya.MultipartFormData(provider: .data({{param.name}}), name: "{{param.value}}", fileName: "{{param.value}}", mimeType: {{param.name}}{% if param.optional %}?{% endif %}.mimeType)
            formData.append({{param.name}}Data)
            {%  endfor %}
            return .upload(.multipart(formData))
        }
        {% endif %}

        {% for param in operation.params %}
        let {{ param.name }}: {% if param.isFile %}Data{% else %}{{ param.type }}{% endif %}{% if param.optional %}?{% endif %}
        {% endfor %}
        {%  if operation.headerParams or operation.bodyParams or operation.queryParams or operation.formParams %}

        var parameters: Parameters? {
            var compositeParameters: CompositeParameters = CompositeParameters()
            {% if operation.headerParams %}

            var headerParams: [String: String] = [:]
            {% for param in operation.headerParams %}
            headerParams["{{ param.value }}"] = {{ param.name }}
            {% endfor %}
            compositeParameters.header = headerParams
            {% endif %}
            {% if operation.queryParams %}

            var queryParams: Parameters = [:]
            {% for param in operation.queryParams %}
            queryParams["{{ param.value }}"] = {{ param.name }}
            {% endfor %}
            compositeParameters.query = queryParams
            {% endif %}
            {% if operation.bodyParams.count >= 0 %}

            var bodyParams: Parameters = [:]
            {% for param in operation.bodyParams %}
            bodyParams["{{ param.value }}"] = {{ param.name }}
            {% endfor %}
            compositeParameters.body = bodyParams
            {% elif operation.formParams %}

            var formParams: Parameters = [:]
            {% for param in operation.formParams where not param.isFile %}
            formParams["{{ param.value }}"] = {{ param.name }}
            {% endfor %}
            compositeParameters.form = formParams
            {% endif %}

            return compositeParameters.toParameters()
        }
        {% endif %}
    }
    {% endfor %}
}
