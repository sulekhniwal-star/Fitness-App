const fs = require('fs');
const data = JSON.parse(fs.readFileSync('pb_schema.json'));
const users = data.find(c => c.name === 'users');

users.schema.unshift(
  { system: true, id: 'text3208210256', name: 'id', type: 'text', required: true, presentable: false, unique: false, options: { min: 15, max: 15, pattern: '^[a-z0-9]+$' } },
  { system: true, id: 'password901924565', name: 'password', type: 'password', required: true, presentable: false, unique: false, options: { min: 8, max: 0, pattern: '' } },
  { system: true, id: 'text2504183744', name: 'tokenKey', type: 'text', required: true, presentable: false, unique: false, options: { min: 30, max: 60, pattern: '' } },
  { system: true, id: 'email3885137012', name: 'email', type: 'email', required: true, presentable: false, unique: false, options: { exceptDomains: null, onlyDomains: null } },
  { system: true, id: 'bool1547992806', name: 'emailVisibility', type: 'bool', required: false, presentable: false, unique: false, options: {} },
  { system: true, id: 'bool256245529', name: 'verified', type: 'bool', required: false, presentable: false, unique: false, options: {} }
);

users.schema.push(
  { system: false, id: 'autodate2990389176', name: 'created', type: 'autodate', required: false, presentable: false, unique: false, options: { onCreate: true, onUpdate: false } },
  { system: false, id: 'autodate3332085495', name: 'updated', type: 'autodate', required: false, presentable: false, unique: false, options: { onCreate: true, onUpdate: true } }
);

users.authRule = '';
users.manageRule = null;
users.authAlert = {
    enabled: true,
    emailTemplate: {
        subject: 'Login from a new location',
        body: '<p>Hello,</p>\\n<p>We noticed a login to your {APP_NAME} account from a new location:</p>\\n<p><em>{ALERT_INFO}</em></p>\\n<p><strong>If this wasn\\'t you, you should immediately change your {APP_NAME} account password to revoke access from all other locations.</strong></p>\\n<p>If this was you, you may disregard this email.</p>\\n<p>\\n  Thanks,<br/>\\n  {APP_NAME} team\\n</p>'
    }
};
users.oauth2 = {
    mappedFields: {
        id: '',
        name: 'name',
        username: '',
        avatarURL: 'avatar'
    },
    enabled: false
};
users.passwordAuth = {
    enabled: true,
    identityFields: ['email']
};
users.mfa = {
    enabled: false,
    duration: 1800,
    rule: ''
};
users.otp = {
    enabled: false,
    duration: 180,
    length: 8,
    emailTemplate: {
        subject: 'OTP for {APP_NAME}',
        body: '<p>Hello,</p>\\n<p>Your one-time password is: <strong>{OTP}</strong></p>\\n<p><i>If you didn\\'t ask for the one-time password, you can ignore this email.</i></p>\\n<p>\\n  Thanks,<br/>\\n  {APP_NAME} team\\n</p>'
    }
};
users.authToken = {
    duration: 604800
};
users.passwordResetToken = {
    duration: 1800
};
users.emailChangeToken = {
    duration: 1800
};
users.verificationToken = {
    duration: 259200
};
users.fileToken = {
    duration: 180
};
users.verificationTemplate = {
    subject: 'Verify your {APP_NAME} email',
    body: '<p>Hello,</p>\\n<p>Thank you for joining us at {APP_NAME}.</p>\\n<p>Click on the button below to verify your email address.</p>\\n<p>\\n  <a class=\\"btn\\" href=\\"{APP_URL}/_/#/auth/confirm-verification/{TOKEN}\\" target=\\"_blank\\" rel=\\"noopener\\">Verify</a>\\n</p>\\n<p>\\n  Thanks,<br/>\\n  {APP_NAME} team\\n</p>'
};
users.resetPasswordTemplate = {
    subject: 'Reset your {APP_NAME} password',
    body: '<p>Hello,</p>\\n<p>Click on the button below to reset your password.</p>\\n<p>\\n  <a class=\\"btn\\" href=\\"{APP_URL}/_/#/auth/confirm-password-reset/{TOKEN}\\" target=\\"_blank\\" rel=\\"noopener\\">Reset password</a>\\n</p>\\n<p><i>If you didn\\'t ask to reset your password, you can ignore this email.</i></p>\\n<p>\\n  Thanks,<br/>\\n  {APP_NAME} team\\n</p>'
};
users.confirmEmailChangeTemplate = {
    subject: 'Confirm your {APP_NAME} new email address',
    body: '<p>Hello,</p>\\n<p>Click on the button below to confirm your new email address.</p>\\n<p>\\n  <a class=\\"btn\\" href=\\"{APP_URL}/_/#/auth/confirm-email-change/{TOKEN}\\" target=\\"_blank\\" rel=\\"noopener\\">Confirm new email</a>\\n</p>\\n<p><i>If you didn\\'t ask to change your email address, you can ignore this email.</i></p>\\n<p>\\n  Thanks,<br/>\\n  {APP_NAME} team\\n</p>'
};

fs.writeFileSync('pb_schema.json', JSON.stringify(data, null, 2));
