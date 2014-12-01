describe 'Unit: MainController', ->
  beforeEach module 'app.weebook'

  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new();
    ctrl = $controller('MainController', $scope: scope)

  it 'should create $scope.greeting when calling sayHello', ->
    expect(scope.greeting).toBeUndefined()
    scope.sayHello();
    expect(scope.greeting).toEqual("Hello Ari")
