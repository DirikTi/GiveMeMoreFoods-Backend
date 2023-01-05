import { PATH, SECRET_KEYS } from '../src/Config.js';
import jwt from 'jsonwebtoken';
import { Expo } from 'expo-server-sdk';
import mysqlAsi from '../src/database/MysqlAsi.js';


const expo = new Expo({ accessToken: "" })

function LogSystemNotify() {
	let query = "INSERT INTO "

	mysqlAsi.executeQueryAsync()
}

export const AsiNotification = {
	type: {
		friendRequestNotification(whoWantToBeFriend, lang = "en", tokens) {
			let bodyMessage = "";
			let title = "";
			let subtitle = "";
			console.log(lang);
			if (lang == "en") {
				bodyMessage = whoWantToBeFriend + " wants to be friend with you :)";
				title = "Friend Requet";
				subtitle = "Friend Request Subtitle";
			} else if (lang == "tr") {
				bodyMessage = whoWantToBeFriend + " seninle arkadaş olmak istiyor :)";
				title = "Arkadaşlık isteği";
				subtitle = "Arkadaşlık isteği Subtitle";
			} else {
				bodyMessage = whoWantToBeFriend + " wants to be friend with you :)";
				title = "Friend Requet";
				subtitle = "Friend Request Subtitle";
			}

			sendSingleTarget({
				message: bodyMessage,
				title,
				subtitle,
				sound: "default",
			}, tokens, "normal", {});
		},
		inviteDictionaryNotification(whoWantsMe, category, dictionaryName, lang = "en", tokens) {
			let bodyMessage = "";
			let title = "";
			let subtitle = "";

			sendSingleTarget({
				message: bodyMessage,
				title,
				subtitle,
				sound: "default",
			}, tokens, "normal", {});
		},
		waitingCommitNotification(whoPushed, category, dictionaryName, lang = "en", tokens) {
			let bodyMessage = "";
			let title = "";
			let subtitle = "";

			if (lang == "en") {
				bodyMessage = whoPushed + " pushed a new commit in '" + category + " - " + dictionaryName + "' dictionary";
				title = "Commit Waiting";
				subtitle = "Commit Waiting Subtitle";
			} else if (lang == "tr") {
				bodyMessage = whoPushed + " '" + category + " - " + dictionaryName + "' sözlüğüne yeni bir commit pushladı";
				title = "Commit Bekleniyor";
				subtitle = "Commit Bekleniyor Subtitle"
			} else {
				bodyMessage = whoPushed + " pushed a new commit in '" + category + " - " + dictionaryName + "' dictionary";
				title = "Commit Waiting";
				subtitle = "Commit Waiting Subtitle";
			}

			sendSingleTarget({
				message: bodyMessage,
				title,
				subtitle,
				sound: "default",
			}, tokens, "normal", {});
		},
		addedNewWordsToLibraryNotification(category, dictionaryName, users) { // DONE

			let notificationMessages = {
				en: {
					bodyMessage: "'" + category + " - " + dictionaryName + "' was added new words.",
					title: "New Words In Library",
					subtitle: "New Words In Library Subtitle",
				},
				tr: {
					bodyMessage: "'" + category + " - " + dictionaryName + "' sözlüğüne yeni kelimeler eklendi",
					title: "Yeni Kelimeler",
					subtitle: "Yeni Kelimeler Subtitle",
				},
			}

			users.forEach((user) => {
				let notificationMessage = notificationMessages[user.language] == undefined ?
					notificationMessages["en"] : notificationMessages[user.language]
				sendSingleTarget({
					...notificationMessage,
					sound: "default",
				}, [user.notification_token], "normal", {});
			})
		},
		commentDictionaryNotification(comment_text ,username, category_name, dictionary_name, users) {
			let notificationMessages = {
				en: {
					bodyMessage: username + " commented '" + comment_text + "' to " + category_name + " - " + dictionary_name + "",
					title: "Commented Your Dictionary",
					subtitle: "Commented Your Dictionary Subtitle",
				},
				tr: {
					bodyMessage: username + " " + category_name + " - " + dictionary_name + " sözlüğüne '" + comment_text + "' yorum yaptı",
					title: username + " sözlüğüne yorum  yaptı",
					subtitle: username + " sözlüğüne yorum  yaptı Subtitle",
				},
			}

			users.forEach((user) => {
				let notificationMessage = notificationMessages[user.language] == undefined ?
					notificationMessages["en"] : notificationMessages[user.language]
				sendSingleTarget({
					...notificationMessage,
					sound: "default",
				}, [user.notification_token], "normal", {});
			})
		},
		answerCommentNotification(comment_text, username, category_name, dictionary_name, notification_token) {
			let bodyMessage = "";
			let title = "";
			let subtitle = "";

			if (lang == "en") { 
				bodyMessage = whoPushed + " pushed a new commit in '" + category + " - " + dictionaryName + "' dictionary";
				title = "Commit Waiting";
				subtitle = "Commit Waiting Subtitle";
			} else if (lang == "tr") {
				bodyMessage = whoPushed + " '" + category + " - " + dictionaryName + "' sözlüğüne yeni bir commit pushladı";
				title = "Commit Bekleniyor";
				subtitle = "Commit Bekleniyor Subtitle"
			} else {
				bodyMessage = whoPushed + " pushed a new commit in '" + category + " - " + dictionaryName + "' dictionary";
				title = "Commit Waiting";
				subtitle = "Commit Waiting Subtitle";
			}

			sendSingleTarget({ 
				message: bodyMessage,
				title,
				subtitle,
				sound: "default",
			}, [notification_token], "normal", {});

		}
	},
}

/**
 * 
 * @param {import('../src/models/types/OtherModels').MyNotificationModel} _body 
 * @param {String[]} regTokens 
 * @param {"normal" | "default" | "high" } priority
 * @param {Object} data
 * 
 * @description Send Notification datas
 */
function sendSingleTarget(_body, regTokens, priority = "normal", data) {
	let messages = [];

	for (let pushToken of regTokens) {
		if (!Expo.isExpoPushToken(pushToken)) {
			console.error("Push token " + pushToken + " is not a vaid Expo push token");
			continue;
		}

		let message = {
			to: pushToken,
			sound: ('sound' in _body) ? _body.sound : "default",
			title: _body.title,
			subTitle: _body.subtitle,
			priority,
			body: _body.message,
			data: data,
		};
		// ttl, channelId, expiration

		('badge' in _body) ? message.badge = _body.badge : null;
		('vibrate' in _body) ? message.vibrate = _body.vibrate : null;

		messages.push(message);
	}

	let chunks = expo.chunkPushNotifications(messages);
	expo.chunkPushNotifications(messages);
	let tickets = [];

	(async () => {
		for (let chunk of chunks) {
			try {
				let ticketChunk = await expo.sendPushNotificationsAsync(chunk);
				tickets.push(...ticketChunk);
				// documentation:
				// https://docs.expo.io/push-notifications/sending-notifications/#individual-errors
			} catch (error) {
				console.error(error);
			}
		}

		let receiptIds = [];
		for (let ticket of tickets) {
			// NOTE: Not all tickets have IDs; for example, tickets for notifications
			// that could not be enqueued will have error information and no receipt ID.
			if (ticket.id) {
				receiptIds.push(ticket.id);
			}
		}

		let receiptIdChunks = expo.chunkPushNotificationReceiptIds(receiptIds);

		for (let chunk of receiptIdChunks) {
			try {
				let receipts = await expo.getPushNotificationReceiptsAsync(chunk);
				console.log(receipts);

				// The receipts specify whether Apple or Google successfully received the
				// notification and information about an error, if one occurred.
				for (let receiptId in receipts) {
					let { status, message, details } = receipts[receiptId];
					if (status === 'ok') {
						continue;
					} else if (status === 'error') {
						console.error(
							`There was an error sending a notification: ${message}`
						);
						if (details && details.error) {
							// The error codes are listed in the Expo documentation:
							// https://docs.expo.io/push-notifications/sending-notifications/#individual-errors
							// You must handle the errors appropriately.
							console.error(`The error code is ${details.error}`);
						}
					}
				}
			} catch (error) {
				console.error(error);
			}
		}

	})();

}