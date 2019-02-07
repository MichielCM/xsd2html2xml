<?xml version="1.0"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	<xsl:template name="add-polyfills">
		<xsl:element name="script">
			<xsl:attribute name="type">text/javascript</xsl:attribute>
			<xsl:text disable-output-escaping="yes">
				/* POLYFILLS */
				
				/* add .matches if not natively supported */
				if (!Element.prototype.matches)
					Element.prototype.matches = Element.prototype.msMatchesSelector || 
												Element.prototype.webkitMatchesSelector;
												
				/* add .closest if not natively supported */
				if (!Element.prototype.closest)
					Element.prototype.closest = function(s) {
						var el = this;
						do {
							if (el.nodeType !== 1) return null;
							if (el.matches(s)) return el;
							el = el.parentElement || el.parentNode;
						} while (el !== null);
						return null;
					};
				
				/* add .forEach if not natively supported */
				if (!NodeList.prototype.forEach) {
					NodeList.prototype.forEach = function(callback){
						var i = 0;
						while (i != this.length) {
							callback.apply(this, [this[i], i, this]);
							i++;
						}
					};
				}
        
        /* add .previousElementSibling if not supported */
        (function (arr) {
          arr.forEach(function (item) {
            if (item.hasOwnProperty('previousElementSibling')) {
              return;
            }
            Object.defineProperty(item, 'previousElementSibling', {
              configurable: true,
              enumerable: true,
              get: function () {
                let el = this;
                while (el = el.previousSibling) {
                  if (el.nodeType === 1) {
                    return el;
                  }
                }
                return null;
              },
              set: undefined
            });
          });
        })([Element.prototype, CharacterData.prototype]);
			</xsl:text>
		</xsl:element>	
	</xsl:template>
	
</xsl:stylesheet>