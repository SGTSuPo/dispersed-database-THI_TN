--CHỌN CƠ SỞ (TỪ SITE CHỦ)
CREATE VIEW Get_Subscribes
AS
	SELECT TENCS=PUBS.description, TENSERVER=subscriber_server
	 FROM sysmergepublications  PUBS, sysmergesubscriptions SUBS
	 WHERE PUBS.pubid = SUBS.pubid AND  publisher <> subscriber_server
GO