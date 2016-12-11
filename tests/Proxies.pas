unit Proxies;

interface

uses classes;

function IsProxyClass(ComponentClass: TClass): Boolean;

implementation

function IsProxyClass(ComponentClass: TClass): Boolean;
begin
 Result := False;
end;

end.
