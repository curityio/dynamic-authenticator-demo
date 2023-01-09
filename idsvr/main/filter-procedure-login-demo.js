/**
 * A filter procedure that filters out every authenticator except the demo login authenticator.
 *
 * @param {se.curity.identityserver.procedures.context.AuthenticatorFilterProcedureContext} context
 * @returns {boolean} true to keep the current authenticator, false to remove it.
 */
function result(context) {
  var demoLoginAuthenticatorId = 'demo-login';
  return context.authenticator.id == demoLoginAuthenticatorId;
}
